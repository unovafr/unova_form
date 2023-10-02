# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class PositiveDecimal < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic positive decimal validation
        numericality: {
          greater_than_or_equal_to: 0
        }
      }.freeze
    end
  end
end