require "test_helper"
require "capybara/cuprite"

Capybara.register_driver :cuprite_headless do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1400, 1400 ],
    browser_options: { "no-sandbox" => nil, "disable-gpu" => nil },
    process_timeout: 15,
    timeout: 10,
    js_errors: true,
    headless: true
  )
end

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1400, 1400 ],
    browser_options: { "no-sandbox" => nil, "disable-gpu" => nil },
    process_timeout: 15,
    timeout: 10,
    js_errors: true,
    headless: false
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite_headless
end
