# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class NegativeDecimal < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic decimal validation
        numericality: {
          less_than_or_equal_to: 0
        }
      }.freeze
    end
  end
end