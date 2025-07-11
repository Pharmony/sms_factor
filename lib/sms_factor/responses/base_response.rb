# frozen_string_literal: true

require 'dry-struct'
require 'sms_factor/types'
require 'sms_factor/errors'

class SmsFactor
  module Responses
    class BaseResponse < Dry::Struct
      transform_keys { |k| k.to_s.gsub('-', '_').to_sym }

      attribute :status, SmsFactor::Types::Strict::Integer
      attribute :message, SmsFactor::Types::Strict::String

      def success?
        status == 1
      end
    end
  end
end
