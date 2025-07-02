# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class CreateTokenResponse < BaseResponse
      attribute :token, SmsFactor::Types::Strict::String
      attribute :token_id, SmsFactor::Types::Strict::String
      attribute :allowed_ips, SmsFactor::Types::Array.of(SmsFactor::Types::Strict::String).optional
    end
  end
end
