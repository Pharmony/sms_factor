# frozen_string_literal: true

class SmsFactor
  class ApiError < StandardError
    attr_reader :status, :message, :details

    def initialize(status, message, details)
      @status = status
      @message = "#{message}: #{details}"
      super("[API error #{status}] #{message}: #{details}")
    end
  end

  class AuthError < ApiError; end
  class XmlError < ApiError; end
  class NotEnoughCreditsError < ApiError; end
  class DateError < ApiError; end
  class ResourceNotFoundError < ApiError; end
  class JsonError < ApiError; end
  class DataError < ApiError; end
  class ModerationError < ApiError; end
  class InvalidTokenIdError < ApiError; end
  class UnknownApiError < ApiError; end
end
