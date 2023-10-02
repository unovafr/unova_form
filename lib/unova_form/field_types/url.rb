# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Url < Base
      INPUT_TYPE = :url

      VALIDATORS = {
        # classic url validation with facultative "http"/"https", and facultative "www.".
        format: { with: /\A(?:https?:\/\/)?(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)\z/, message: :invalid_url_format }
      }.freeze
    end
  end
end