# frozen_string_literal: true

require 'sms_factor/responses/base_response'

class SmsFactor
  module Responses
    class ToggleLockResponse < BaseResponse
      attribute :state, SmsFactor::Types::Strict::String
    end
  end
end
