module UnovaForm
  module FieldTypes
    class SoundFile < Base
      INPUT_TYPE = :file

      VALIDATORS = {
        content_type: { in: %w[audio/mpeg audio/mp4 audio/ogg audio/wav audio/webm audio/x-m4a audio/x-aac audio/x-aiff audio/x-wav] },
        size: { less_than: 20.megabytes }
      }.freeze
    end
  end
end