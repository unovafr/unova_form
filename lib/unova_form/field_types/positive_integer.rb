module UnovaForm
  module FieldTypes
    class PositiveInteger < Base
      INPUT_TYPE = :number

      VALIDATORS = {
        # classic positive integer validation
        numericality: {
          only_integer: true,
          greater_than_or_equal_to: 0
        }
      }.freeze
    end
  end
end