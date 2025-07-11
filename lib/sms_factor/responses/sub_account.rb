# frozen_string_literal: true

require 'dry-struct'
require 'sms_factor/types'

class SmsFactor
  module Responses
    class SubAccount < Dry::Struct
      attribute :client_id, SmsFactor::Types::Coercible::Integer
      attribute :email, SmsFactor::Types::Strict::String
      attribute :firstname, SmsFactor::Types::Strict::String.optional
      attribute :lastname, SmsFactor::Types::Strict::String.optional
      attribute :city, SmsFactor::Types::Strict::String.optional
      attribute :phone, SmsFactor::Types::Strict::String.optional
      attribute :address1, SmsFactor::Types::Strict::String.optional
      attribute :address2, SmsFactor::Types::Strict::String.optional
      attribute :zip, SmsFactor::Types::Strict::String.optional
      attribute :country, SmsFactor::Types::Strict::String.optional
      attribute :country_code, SmsFactor::Types::Strict::String.optional
      attribute :lang, SmsFactor::Types::Strict::String.optional
      attribute :credits, SmsFactor::Types::Coercible::Integer
      attribute :unlimited, SmsFactor::Types::Coercible::Integer
      attribute? :description, SmsFactor::Types::Strict::String.optional
      attribute :senderid, SmsFactor::Types::Strict::String.optional
      attribute :status, SmsFactor::Types::Coercible::Integer
      attribute :time_zone, SmsFactor::Types::Strict::String.optional
      attribute :current_month_consumption, SmsFactor::Types::Coercible::Integer.optional
      attribute :previous_month_consumption, SmsFactor::Types::Coercible::Integer.optional
    end
  end
end
