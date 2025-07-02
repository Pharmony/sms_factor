# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'sms_factor/headers'
require 'sms_factor/response_factory'
require 'sms_factor/responses/balance_response'
require 'sms_factor/responses/create_sub_account_response'
require 'sms_factor/responses/sub_account_response'
require 'sms_factor/responses/sub_accounts_response'
require 'sms_factor/responses/toggle_lock_response'
require 'sms_factor/responses/transfer_credits_response'

class SmsFactor
  class SubAccount
    API_URL = SmsFactor::Init.configuration.api_url

    COMPANY        = 'company'
    ASSOCIATION    = 'association'
    ADMINISTRATION = 'administration'
    PRIVATE        = 'private'

    TYPES = [
      COMPANY,
      ASSOCIATION,
      ADMINISTRATION,
      PRIVATE
    ].freeze

    def create(email:, password:, type:, **account_params)
      validate_create_params(email, password, type)
      payload = build_create_payload(email, password, type, account_params)

      url = "#{API_URL}/account"
      response = RestClient.post(url, payload.to_json, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::CreateSubAccountResponse)
    end

    def list
      url = "#{API_URL}/sub-accounts"
      response = RestClient.get(url, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::SubAccountsResponse)
    end

    def get(sub_account_id)
      url = "#{API_URL}/sub-accounts/#{sub_account_id}"
      response = RestClient.get(url, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::SubAccountResponse)
    end

    def lock(sub_account_id)
      url = "#{API_URL}/account/#{sub_account_id}/lock"
      response = RestClient.get(url, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::ToggleLockResponse)
    end

    def unlock(sub_account_id)
      url = "#{API_URL}/account/#{sub_account_id}/unlock"
      response = RestClient.get(url, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::ToggleLockResponse)
    end

    def balance(api_key = nil)
      url = "#{API_URL}/credits"
      response = RestClient.get(url, SmsFactor::Headers.api_headers(api_key))
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::BalanceResponse)
    end

    def transfer_credits(sub_account_id, credits)
      payload = {
        transfer: {
          to_account: sub_account_id,
          credits: credits
        }
      }

      url = "#{API_URL}/account/transfer"
      response = RestClient.post(url, payload.to_json, SmsFactor::Headers.api_headers)
      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::TransferCreditsResponse)
    end

    private

    def validate_create_params(email, password, type)
      { email: email, password: password, type: type }.each do |key, value|
        raise ArgumentError, "#{key} is required" if value.nil? || value.strip.empty?
      end

      return if TYPES.include?(type)

      raise ArgumentError, "Invalid type: #{type}. Must be one of: #{TYPES.join(', ')}"
    end

    def build_create_payload(email, password, type, account_params)
      account_data = {
        email: email,
        password: password,
        type: type,
        isChild: 1,
        unlimited: 0
      }.merge(account_params).compact

      { account: account_data }
    end
  end
end
