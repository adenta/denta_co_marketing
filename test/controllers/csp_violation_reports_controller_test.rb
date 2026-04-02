require "test_helper"

class CspViolationReportsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "accepts classic csp reports and emails them" do
    perform_enqueued_jobs do
      post csp_violation_reports_path,
        params: {
          "csp-report" => {
            "document-uri" => "https://www.denta.co/blog",
            "effective-directive" => "script-src-elem",
            "violated-directive" => "script-src-elem",
            "blocked-uri" => "https://cdn.example.com/tracker.js",
            "disposition" => "enforce",
            "original-policy" => "default-src 'self'; report-uri /csp-violation-reports"
          }
        }.to_json,
        headers: {
          "CONTENT_TYPE" => "application/csp-report",
          "HTTP_USER_AGENT" => "Mozilla/5.0 Test Browser",
          "HTTP_ORIGIN" => "https://www.denta.co"
        }
    end

    assert_response :no_content

    email = ActionMailer::Base.deliveries.last
    assert_equal [ ENV.fetch("CSP_VIOLATION_RECIPIENT", CspViolationMailer::DEFAULT_RECIPIENT) ], email.to
    assert_equal "[Denta CSP] script-src-elem on https://www.denta.co/blog", email.subject
    assert_match "Blocked URI: https://cdn.example.com/tracker.js", email.body.encoded
    assert_match "Content type: application/csp-report", email.body.encoded
    assert_match "User agent: Mozilla/5.0 Test Browser", email.body.encoded
  end

  test "rejects invalid report payloads" do
    post csp_violation_reports_path,
      params: "{not-json",
      headers: {
        "CONTENT_TYPE" => "application/csp-report"
      }

    assert_response :bad_request
    assert_empty ActionMailer::Base.deliveries
  end
end
