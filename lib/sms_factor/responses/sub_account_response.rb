# frozen_string_literal: true

require 'sms_factor/responses/base_response'
require 'sms_factor/responses/sub_account'

class SmsFactor
  module Responses
    class SubAccountResponse < BaseResponse
      attribute :sub_account do
        attributes_from SmsFactor::Responses::SubAccount
      end
    end
  end
end
