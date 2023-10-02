# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Date < Base
      INPUT_TYPE = :date

      VALIDATORS = {
        # classic date validation
        timeliness: { type: :date }
      }.freeze
    end
  end
end