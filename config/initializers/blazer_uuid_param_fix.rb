Rails.application.config.to_prepare do
  module BlazerUuidParamFix
    UUID_PARAM_PATTERN = /\A[0-9a-f-]{36}/i

    private

    def blazer_record_id_param
      value = params[:id].to_s
      value[UUID_PARAM_PATTERN] || value
    end
  end

  Blazer::DashboardsController.class_eval do
    include BlazerUuidParamFix

    private

    def set_dashboard
      @dashboard = Blazer::Dashboard.find(blazer_record_id_param)
    end
  end

  Blazer::QueriesController.class_eval do
    include BlazerUuidParamFix

    private

    def set_query
      @query = Blazer::Query.find(blazer_record_id_param)
    end
  end
end
