ENV["RAILS_ENV"] ||= "test"
ENV["OPENROUTER_API_KEY"] ||= "test-openrouter-key"

require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module TestMethodStubbing
  def with_stubbed_singleton_method(object, method_name, implementation)
    singleton_class = class << object; self; end
    method_defined = singleton_class.method_defined?(method_name)
    original_method = singleton_class.instance_method(method_name) if method_defined

    singleton_class.define_method(method_name, &implementation)
    yield
  ensure
    if method_defined
      singleton_class.define_method(method_name, original_method)
    elsif singleton_class.method_defined?(method_name)
      singleton_class.remove_method(method_name)
    end
  end
end

ActiveSupport::TestCase.include(TestMethodStubbing)
ActionDispatch::IntegrationTest.include(TestMethodStubbing)
ActionMailbox::TestCase.include(TestMethodStubbing) if defined?(ActionMailbox::TestCase)
ActionMailer::TestCase.include(TestMethodStubbing)
