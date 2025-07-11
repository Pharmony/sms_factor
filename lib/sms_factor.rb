# frozen_string_literal: true

require 'json'
require 'nokogiri'
require 'rest-client'

class SmsFactor
  attr_accessor :message, :recipients, :sender

  def initialize(message, recipients, sender = nil)
    if SmsFactor::Init.configuration.invalid?
      raise 'The configuration is not complete. Please define api_url, api_login, api_password and api_default_from"'
    end

    @sender ||= sender || SmsFactor::Init.configuration.api_default_from
    @recipients = Array(recipients)
    @message = message
  end

  def build_deliver_data
    {
      sms: {
        message: { text: @message, sender: @sender, pushtype: 'alert' },
        recipients: {
          gsm: @recipients.collect { |recipient| { value: recipient } }
        }
      }
    }
  end

  def credentials_auth
    @credentials_auth ||= {
      authentication: {
        username: SmsFactor::Init.configuration.api_login,
        password: SmsFactor::Init.configuration.api_password
      }
    }
  end

  def deliver(delay: :now, check: false, api_key: nil)
    SmsFactor::SmsResponse.new(
      RestClient.post(
        sms_factor_url(check),
        { data: build_deliver_data_from(delay).to_json },
        SmsFactor::Headers.api_headers(api_key)
      )
    )
  end

  def self.sms(message, recipients, sender = nil)
    SmsFactor.new(message, recipients, sender).deliver
  end

  private

  def build_deliver_data_from(delay)
    data = if delay.nil? || delay == :now
             build_deliver_data
           else
             build_deliver_data[:sms].merge!(delay: delay)
           end

    data[:sms].merge!(credentials_auth) unless SmsFactor::Init.configuration.api_auth?

    data
  end

  def sms_factor_url(check)
    url = "#{SmsFactor::Init.configuration.api_url}/send"
    url += '/simulate' if check
    url
  end
end

# core utils
require 'sms_factor/configuration'
require 'sms_factor/errors'
require 'sms_factor/headers'
require 'sms_factor/init'
require 'sms_factor/response_factory'
require 'sms_factor/types'

# responses
require 'sms_factor/sms_response'
Dir[File.expand_path('sms_factor/responses/**/*.rb', __dir__)].sort.each { |f| require f }

# services
require 'sms_factor/sub_account'
require 'sms_factor/token'
