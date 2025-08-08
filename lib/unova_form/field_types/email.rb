# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Email < Base
      INPUT_TYPE = :email

      # noinspection RegExpRedundantEscape - javascript needs the backslashes for pattern matching
      VALIDATORS = {
        # classic email validation like native html input email.
        format: { with: /\A[a-zA-Z0-9.!#$%&’*+\/=?^_`\{\|\}~\-]+@[a-zA-Z0-9\-]+(?:\.[a-zA-Z0-9\-]+)+\z/, key: :invalid_email_format ,message: :invalid_email_format }
      }.freeze
    end
  end
end