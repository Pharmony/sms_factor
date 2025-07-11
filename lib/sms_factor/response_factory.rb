# frozen_string_literal: true

class SmsFactor
  class ResponseFactory
    ERROR_CLASSES = {
      -1 => SmsFactor::AuthError,
      -2 => SmsFactor::XmlError,
      -3 => SmsFactor::NotEnoughCreditsError,
      -4 => SmsFactor::DateError,
      -5 => SmsFactor::ResourceNotFoundError,
      -6 => SmsFactor::JsonError,
      -7 => SmsFactor::DataError,
      -8 => SmsFactor::ModerationError,
      -10 => SmsFactor::InvalidTokenIdError
    }.freeze

    def self.build(response, klass)
      parsed = JSON.parse(response.body, symbolize_names: true)

      unless parsed[:status] == 1
        raise error_class(parsed[:status]).new(parsed[:status], parsed[:message], parsed[:details])
      end

      klass.new(parsed)
    end

    def self.error_class(status)
      ERROR_CLASSES[status] || SmsFactor::UnknownApiError
    end
  end
end
