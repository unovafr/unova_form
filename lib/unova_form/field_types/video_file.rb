# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class VideoFile < Base
      INPUT_TYPE = :file

      VALIDATORS = {
        content_type: { in: %w[video/mp4 video/x-flv video/quicktime video/x-msvideo video/x-ms-wmv video/3gpp video/3gpp2 video/ogg video/webm] },
        size: { less_than: 50.megabytes }
      }.freeze
    end
  end
end