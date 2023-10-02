# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Decimal < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic decimal validation
        numericality: true
      }.freeze
    end
  end
end