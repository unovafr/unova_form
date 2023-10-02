# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Month < Base
      INPUT_TYPE = :month

      VALIDATORS = {
        # classic datetime validation
        format: { with: /\A\d{4}-\d{2}\z/, message: :invalid_month_format }
      }.freeze
    end
  end
end