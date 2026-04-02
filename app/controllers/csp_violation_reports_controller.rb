class CspViolationReportsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  def create
    report = parsed_report
    return head :bad_request if report.blank?

    CspViolationMailer.with(
      report: report,
      content_type: request.content_type,
      ip_address: request.remote_ip,
      origin: request.headers["Origin"],
      user_agent: request.user_agent
    ).violation_report.deliver_later

    head :no_content
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def parsed_report
    payload = JSON.parse(request.raw_post)

    if payload.is_a?(Hash)
      return payload.fetch("csp-report", payload)
    end

    if payload.is_a?(Array)
      csp_report = payload.find { |entry| entry["type"] == "csp-violation" } if payload.all?(Hash)
      return csp_report&.fetch("body", nil)
    end

    nil
  end
end
