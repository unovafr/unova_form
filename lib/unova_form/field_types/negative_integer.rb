# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class NegativeInteger < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic positive integer validation
        numericality: {
          only_integer: true,
          less_than_or_equal_to: 0
        }
      }.freeze
    end
  end
end