# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Integer < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic positive integer validation
        numericality: {
          only_integer: true
        }
      }.freeze
    end
  end
end