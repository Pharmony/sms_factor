# frozen_string_literal: true

class SmsFactor
  module Headers
    def self.api_headers(api_key = nil)
      headers = {
        accept: :json,
        content_type: :json,
        verify_ssl: false
      }

      if SmsFactor::Init.configuration.api_auth?
        headers[:Authorization] = "Bearer #{api_key || SmsFactor::Init.configuration.api_key}"
      end

      headers
    end
  end
end
