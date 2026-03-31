Rails.application.config.generators do |g|
  g.assets false
  g.helper false
  g.orm :active_record, primary_key_type: :uuid
  g.stylesheets false
  g.template_engine nil
end
