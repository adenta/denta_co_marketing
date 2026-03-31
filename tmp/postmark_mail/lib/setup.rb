# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"
require "pathname"
require "uri"
require "yaml"

module TmpPostmarkMail
  ROOT = Pathname.new(__dir__).join("..", "..", "..").expand_path
  OUTPUT_DIR = ROOT.join("tmp", "postmark_mail", "output")

  class Error < StandardError; end

  module Env
    module_function

    def load!(path = ROOT.join(".env"))
      return ENV unless path.exist?

      path.read.each_line do |line|
        stripped = line.strip
        next if stripped.empty? || stripped.start_with?("#")

        key, raw_value = stripped.split("=", 2)
        next if key.nil? || raw_value.nil?
        next if ENV.key?(key)

        ENV[key] = unquote(raw_value.strip)
      end

      ENV
    end

    def unquote(value)
      return value unless value.length >= 2

      quote = value[0]
      return value unless [ "\"", "'" ].include?(quote) && value[-1] == quote

      value[1..-2]
    end
  end

  class Config
    attr_reader :zone_name, :mail_domain, :return_path_domain, :dmarc_value

    def initialize(env = ENV)
      @zone_name = env.fetch("CLOUDFLARE_ZONE_NAME", inferred_zone_name)
      @mail_domain = env.fetch("MAIL_DOMAIN", "mail.#{@zone_name}")
      @return_path_domain = env.fetch("POSTMARK_RETURN_PATH_DOMAIN", "pm-bounces.#{@mail_domain}")
      @dmarc_value = env.fetch("DMARC_VALUE", "v=DMARC1; p=none;")
    end

    def dmarc_host
      "_dmarc.#{mail_domain}"
    end

    private

    def inferred_zone_name
      deploy_path = ROOT.join("config", "deploy.yml")
      return "denta.co" unless deploy_path.exist?

      deploy = YAML.load_file(deploy_path)
      Array(deploy.dig("proxy", "hosts")).first || "denta.co"
    rescue Psych::SyntaxError
      "denta.co"
    end
  end

  class Snapshot
    def self.write(name, payload)
      FileUtils.mkdir_p(OUTPUT_DIR)
      path = OUTPUT_DIR.join(name)
      path.write(JSON.pretty_generate(payload))
      path
    end
  end

  class HttpClient
    def get(url, headers: {})
      request(Net::HTTP::Get, url, headers:)
    end

    def post(url, headers: {}, body: nil)
      request(Net::HTTP::Post, url, headers:, body:)
    end

    def put(url, headers: {}, body: nil)
      request(Net::HTTP::Put, url, headers:, body:)
    end

    private

    def request(klass, url, headers:, body: nil)
      uri = URI(url)
      request = klass.new(uri)
      headers.each { |key, value| request[key] = value }
      request.body = JSON.dump(body) if body

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      payload =
        if response.body.to_s.strip.empty?
          {}
        else
          JSON.parse(response.body)
        end

      { status: response.code.to_i, ok: response.is_a?(Net::HTTPSuccess), body: payload }
    rescue JSON::ParserError
      raise Error, "Non-JSON response from #{url}: #{response.body}"
    end
  end

  class PostmarkClient
    API_BASE = "https://api.postmarkapp.com"

    def initialize(account_token:, server_token: ENV["POSTMARK_SERVER_TOKEN"] || ENV["POSTMARK_SENDING_TOKEN"], http: HttpClient.new)
      @account_token = account_token
      @server_token = server_token
      @http = http
    end

    def domains
      response = @http.get("#{API_BASE}/domains?count=100&offset=0", headers: account_headers)
      ensure_ok!(response, "list Postmark domains")
      response.fetch(:body).fetch("Domains")
    end

    def find_domain(name)
      domains.find { |domain| domain.fetch("Name") == name }
    end

    def ensure_domain(name)
      domain = find_domain(name)
      return domain_details(domain.fetch("ID")) if domain

      response = @http.post(
        "#{API_BASE}/domains",
        headers: account_headers,
        body: { "Name" => name, "ReturnPathDomain" => "pm-bounces.#{name}" }
      )
      ensure_ok!(response, "create Postmark domain #{name}")
      domain_details(response.fetch(:body).fetch("ID"))
    end

    def domain_details(id)
      response = @http.get("#{API_BASE}/domains/#{id}", headers: account_headers)
      ensure_ok!(response, "fetch Postmark domain #{id}")
      response.fetch(:body)
    end

    def server
      raise Error, "POSTMARK_SERVER_TOKEN is required for server-level calls" if @server_token.to_s.empty?

      response = @http.get("#{API_BASE}/server", headers: server_headers)
      ensure_ok!(response, "fetch Postmark server")
      response.fetch(:body)
    end

    private

    def account_headers
      {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "X-Postmark-Account-Token" => @account_token
      }
    end

    def server_headers
      {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "X-Postmark-Server-Token" => @server_token
      }
    end

    def ensure_ok!(response, action)
      return if response.fetch(:ok)

      message =
        if response.fetch(:body).is_a?(Hash)
          response.fetch(:body)["Message"] || response.fetch(:body)["ErrorCode"] || response.fetch(:body).inspect
        else
          response.fetch(:body).to_s
        end

      raise Error, "Could not #{action} (HTTP #{response.fetch(:status)}): #{message}"
    end
  end

  class CloudflareClient
    API_BASE = "https://api.cloudflare.com/client/v4"

    def initialize(token:, http: HttpClient.new)
      @token = token
      @http = http
    end

    def zone(name)
      response = @http.get("#{API_BASE}/zones?#{URI.encode_www_form(name:, status: "active", per_page: 50)}", headers:)
      ensure_ok!(response, "look up Cloudflare zone #{name}")
      zones = response.fetch(:body).fetch("result")
      zones.find { |zone| zone.fetch("name") == name } || raise(Error, "Cloudflare zone #{name} was not found")
    end

    def upsert_record(zone_id:, record:)
      existing = matching_records(zone_id:, type: record.fetch(:type), name: record.fetch(:name))

      if existing.empty?
        create_record(zone_id:, record:)
      elsif existing.length == 1
        update_record(zone_id:, record_id: existing.first.fetch("id"), record:)
      else
        return exact_match(existing, record) if exact_match(existing, record)

        raise Error, "Refusing to update #{record.fetch(:type)} #{record.fetch(:name)} because multiple records already exist"
      end
    end

    private

    def matching_records(zone_id:, type:, name:)
      response = @http.get(
        "#{API_BASE}/zones/#{zone_id}/dns_records?#{URI.encode_www_form(type:, per_page: 100)}",
        headers:
      )
      ensure_ok!(response, "list Cloudflare DNS records")
      response.fetch(:body).fetch("result").select { |record| record.fetch("type") == type && record.fetch("name") == name }
    end

    def create_record(zone_id:, record:)
      response = @http.post("#{API_BASE}/zones/#{zone_id}/dns_records", headers:, body: payload(record))
      ensure_ok!(response, "create #{record.fetch(:type)} #{record.fetch(:name)}")
      response.fetch(:body).fetch("result")
    end

    def update_record(zone_id:, record_id:, record:)
      response = @http.put("#{API_BASE}/zones/#{zone_id}/dns_records/#{record_id}", headers:, body: payload(record))
      ensure_ok!(response, "update #{record.fetch(:type)} #{record.fetch(:name)}")
      response.fetch(:body).fetch("result")
    end

    def exact_match(records, desired)
      records.find do |record|
        record.fetch("content") == desired.fetch(:content) &&
          integerish(record["ttl"]) == integerish(desired[:ttl]) &&
          integerish(record["priority"]) == integerish(desired[:priority]) &&
          record["proxied"] == desired[:proxied]
      end
    end

    def integerish(value)
      value.nil? ? nil : value.to_i
    end

    def payload(record)
      payload = {
        "type" => record.fetch(:type),
        "name" => record.fetch(:name),
        "content" => record.fetch(:content),
        "ttl" => record.fetch(:ttl, 1)
      }
      payload["priority"] = record[:priority] if record.key?(:priority)
      payload["proxied"] = record[:proxied] if record.key?(:proxied)
      payload
    end

    def headers
      {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@token}"
      }
    end

    def ensure_ok!(response, action)
      return if response.fetch(:ok)

      errors = Array(response.fetch(:body)["errors"]).map { |error| error["message"] }.compact
      raise Error, "Could not #{action} (HTTP #{response.fetch(:status)}): #{errors.join(', ')}"
    end
  end

  class DnsPlan
    def initialize(domain_details:, config:)
      @domain = domain_details
      @config = config
    end

    def records
      planned = []
      planned << dkim_record if dkim_record
      planned << spf_record if spf_record
      planned << return_path_record if return_path_record
      planned << inbound_mx_record
      planned << dmarc_record
      planned
    end

    private

    attr_reader :domain, :config

    def dkim_record
      host = presence(domain["DKIMPendingHost"]) || presence(domain["DKIMHost"])
      value = presence(domain["DKIMPendingTextValue"]) || presence(domain["DKIMTextValue"])
      return unless host && value

      { type: "TXT", name: normalize_name(host), content: value, ttl: 1 }
    end

    def spf_record
      host = presence(domain["SPFHost"])
      value = presence(domain["SPFTextValue"])
      return unless host && value

      { type: "TXT", name: normalize_name(host), content: value, ttl: 1 }
    end

    def return_path_record
      host = presence(domain["ReturnPathDomain"])
      value = presence(domain["ReturnPathDomainCNAMEValue"])
      return unless host && value

      { type: "CNAME", name: normalize_name(host), content: normalize_name(value), ttl: 1, proxied: false }
    end

    def inbound_mx_record
      { type: "MX", name: config.mail_domain, content: "inbound.postmarkapp.com", ttl: 1, priority: 10 }
    end

    def dmarc_record
      { type: "TXT", name: config.dmarc_host, content: config.dmarc_value, ttl: 1 }
    end

    def normalize_name(value)
      value.to_s.sub(/\.\z/, "")
    end

    def presence(value)
      string = value.to_s.strip
      string.empty? ? nil : string
    end
  end
end
