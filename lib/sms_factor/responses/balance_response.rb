# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class BalanceResponse < BaseResponse
      attribute :credits, SmsFactor::Types::Coercible::Integer
      attribute :postpaid, SmsFactor::Types::Coercible::Integer
      attribute :postpaid_limit, SmsFactor::Types::Strict::Bool | SmsFactor::Types::Coercible::Integer
      attribute :unlimited, SmsFactor::Types::Strict::Bool
    end
  end
end
