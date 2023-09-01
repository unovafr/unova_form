module UnovaForm
  module FieldTypes
    class DateTime < Base
      INPUT_TYPE = :"datetime-local"

      VALIDATORS = {
        # classic datetime validation
        timeliness: { type: :datetime }
      }.freeze
    end
  end
end