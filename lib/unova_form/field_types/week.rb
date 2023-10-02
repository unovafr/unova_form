# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Week < Base
      INPUT_TYPE = :week

      VALIDATORS = {
        # classic datetime validation
        format: { with: /\A\d{4}-W\d{2}\z/, message: :invalid_week_format }
      }.freeze
    end
  end
end