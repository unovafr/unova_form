# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class DocumentFile < Base
      INPUT_TYPE = :file

      VALIDATORS = {
        content_type: { in: %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation] },
        size: { less_than: 20.megabytes }
      }.freeze
    end
  end
end