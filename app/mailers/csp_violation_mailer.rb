class CspViolationMailer < ApplicationMailer
  DEFAULT_RECIPIENT = "andrew@denta.co".freeze

  def violation_report
    @report = params.fetch(:report)
    @content_type = params[:content_type]
    @ip_address = params[:ip_address]
    @origin = params[:origin]
    @user_agent = params[:user_agent]

    mail(
      to: ENV.fetch("CSP_VIOLATION_RECIPIENT", DEFAULT_RECIPIENT),
      subject: "[Denta CSP] #{report_summary}"
    )
  end

  private

  def report_summary
    effective_directive = @report["effective-directive"].presence || @report["violated-directive"].presence || "violation"
    document_uri = @report["document-uri"].presence || "(unknown document)"

    "#{effective_directive} on #{document_uri}"
  end
end
