# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class TransferCreditsResponse < BaseResponse
      attribute :credits, SmsFactor::Types::Coercible::Integer
      attribute :child_credits, SmsFactor::Types::Coercible::Integer
    end
  end
end
