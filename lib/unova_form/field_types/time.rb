# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Time < Base
      INPUT_TYPE = :time

      VALIDATORS = {
        # classic time validation
        timeliness: { type: :time }
      }.freeze
    end
  end
end