# frozen_string_literal: true

require 'dry-struct'
require 'sms_factor/types'

class SmsFactor
  module Responses
    class TokenDetails < Dry::Struct
      attribute :name, SmsFactor::Types::Strict::String
      attribute :api_token_id, SmsFactor::Types::Coercible::Integer
      attribute :created_at, SmsFactor::Types::Strict::String
      attribute :expired_at, SmsFactor::Types::Strict::String.optional
      attribute :ttl, SmsFactor::Types::Coercible::Integer.optional
      attribute :is_active, SmsFactor::Types::Coercible::Integer
      attribute :allowed_ips, SmsFactor::Types::Array.of(SmsFactor::Types::Strict::String).optional
    end
  end
end
