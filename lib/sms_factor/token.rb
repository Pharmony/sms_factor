# frozen_string_literal: true

require 'rest-client'
require 'json'
require 'sms_factor/headers'
require 'sms_factor/response_factory'
require 'sms_factor/responses/token_response'
require 'sms_factor/responses/tokens_response'
require 'sms_factor/responses/delete_token_response'

class SmsFactor
  class Token
    API_URL = SmsFactor::Init.configuration.api_url

    def create_for_main_account(name:, ttl: nil, allowed_ips: nil)
      url = "#{API_URL}/token"
      create_token(url, name: name, ttl: ttl, allowed_ips: allowed_ips)
    end

    def create_for_sub_account(sub_account_id:, name:, ttl: nil, allowed_ips: nil)
      url = "#{API_URL}/token/account/#{sub_account_id}"
      create_token(url, name: name, ttl: ttl, allowed_ips: allowed_ips)
    end

    def list(api_key: nil)
      url = "#{API_URL}/token"

      response = RestClient.get(
        url,
        SmsFactor::Headers.api_headers(api_key)
      )

      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::TokensResponse)
    end

    def get(token_id:, api_key: nil)
      url = "#{API_URL}/token/#{token_id}"

      response = RestClient.get(
        url,
        SmsFactor::Headers.api_headers(api_key)
      )

      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::TokenResponse)
    end

    def delete(token_id:, api_key: nil)
      url = "#{API_URL}/token/#{token_id}"

      response = RestClient.delete(
        url,
        SmsFactor::Headers.api_headers(api_key)
      )

      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::DeleteTokenResponse)
    end

    private

    def create_token(url, name:, ttl:, allowed_ips:)
      payload = build_create_payload(name, ttl, allowed_ips)

      response = RestClient.post(
        url,
        payload.to_json,
        SmsFactor::Headers.api_headers
      )

      SmsFactor::ResponseFactory.build(response, SmsFactor::Responses::CreateTokenResponse)
    end

    def build_create_payload(name, ttl, allowed_ips)
      {
        token: {
          name: name,
          ttl: ttl,
          allowed_ips: allowed_ips
        }.compact
      }
    end
  end
end
