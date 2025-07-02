# frozen_string_literal: true

require 'sms_factor/responses/base_response'
require 'sms_factor/responses/token_details'

class SmsFactor
  module Responses
    class TokenResponse < BaseResponse
      attribute :token do
        attributes_from SmsFactor::Responses::TokenDetails
      end
    end
  end
end
