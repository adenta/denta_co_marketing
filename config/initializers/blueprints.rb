# #STYLE_GUIDE: Blueprinter configuration for snake_case JSON responses
# No transformation needed - frontend uses snake_case to match backend.

Oj.default_options = {
  mode: :custom,
  bigdecimal_as_decimal: true
}

Blueprinter.configure do |config|
  config.generator = Oj
end
