# frozen_string_literal: true

require 'sms_factor/responses/base_response'
require 'sms_factor/responses/sub_account'

class SmsFactor
  module Responses
    class SubAccountsResponse < BaseResponse
      attribute :sub_accounts, SmsFactor::Types::Strict::Array.of(SmsFactor::Responses::SubAccount)
    end
  end
end
