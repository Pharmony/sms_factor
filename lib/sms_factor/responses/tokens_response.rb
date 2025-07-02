# frozen_string_literal: true

require 'sms_factor/responses/base_response'
require 'sms_factor/responses/token_details'

class SmsFactor
  module Responses
    class TokensResponse < BaseResponse
      attribute :tokens, SmsFactor::Types::Strict::Array.of(SmsFactor::Responses::TokenDetails)
    end
  end
end
