# frozen_string_literal: true

require 'bundler/setup'
Bundler.setup

require 'ffaker'
require 'sms_factor'
require 'webmock/rspec'
require 'vcr'

SMS_FACTOR_API_KEY = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMTA1NiIsImlhdCI6MTY4MTIwMjU4MC44NzcyMDd9.qtUYY' \
                     'JtoIJOJT5EEOs1Bjs5l4rx7VDXI5ZJ10BZ6JtY'

RSpec.configure do |config|
  config.around do |example|
    # Just disable the VCR, the configuration for its usage
    # will be done in a shared_context
    if example.metadata[:vcr]
      example.run
    else
      VCR.turned_off { example.run }
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

shared_context 'with vcr', :vcr do
  # Disable new records on CI. Most of the CI providers
  # configure environment variable called CI.
  let(:cassette_record) { ENV['CI'] ? :none : :new_episodes }

  around do |example|
    if defined?(cassette_name)
      VCR.turn_on!

      VCR.use_cassette(cassette_name, { record: cassette_record }) do
        example.run
      end

      VCR.turn_off!
    else
      example.run
    end
  end
end

Dir[File.join(__dir__, 'support/**/*.rb')].sort.each { |f| require f }
