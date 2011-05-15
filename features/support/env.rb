require 'cucumber/rails'
require 'webrat'
require 'webrat/core/matchers'
require 'rspec'
require 'rspec/rails'
require 'auth_info'

Webrat.configure do |config|
  config.mode = :rack
  config.open_error_files = false # Set to true if you want error pages to pop up in the browser
end

World Devise::TestHelpers
World Warden::Test::Helpers
World Rack::Test::Methods
World Webrat::Methods
World Webrat::Matchers
World Devise::Controllers::Helpers

module Rack
  module Test
    DEFAULT_HOST = "example.com"
  end
end

Before do
Fixtures.reset_cache
  %w[tweets users authentications].each do |name|
    Fixtures.create_fixtures("db/fixtures/cucumber",name)
  end
end


Before do
  OmniAuth.config.test_mode = true # short circuit
end

ActionController::Base.allow_rescue = false
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

