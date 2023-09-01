module UnovaForm
  module FieldTypes
    class Color < Base
      INPUT_TYPE = :color

      VALIDATORS = {
        # classic color validation
        format: { with: /\A#[a-f0-9]{6}\z/, message: :invalid_color_format }
      }.freeze
    end
  end
end