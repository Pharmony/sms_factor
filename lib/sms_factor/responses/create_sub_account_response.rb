# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class CreateSubAccountResponse < BaseResponse
      attribute :id, SmsFactor::Types::Coercible::Integer
      attribute :active, SmsFactor::Types::Coercible::Integer
    end
  end
end
