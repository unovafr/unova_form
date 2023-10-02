# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class ImageFile < Base
      INPUT_TYPE = :file

      VALIDATORS = {
        content_type: { in: %w[image/bmp image/jpeg image/x-png image/png image/webp image/gif] },
        size: { less_than: 5.megabytes }
      }.freeze
    end
  end
end