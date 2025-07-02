# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class DeleteTokenResponse < BaseResponse
      attribute :deleted_token, SmsFactor::Types::Coercible::Integer
    end
  end
end
