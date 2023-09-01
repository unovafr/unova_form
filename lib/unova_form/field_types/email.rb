module UnovaForm
  module FieldTypes
    class Email < Base
      INPUT_TYPE = :email

      VALIDATORS = {
        # classic email validation like native html input email.
        format: { with: /\A[a-zA-Z0-9.!#$%&’*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+\z/, message: :invalid_email_format }
      }.freeze
    end
  end
end