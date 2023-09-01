module UnovaForm
  module FieldTypes
    class Password < Base
      INPUT_TYPE = :password

      VALIDATORS = {
        # classic password validation regex that tests if there is one of [!@#$%^&*()_+-=[]{};':"\|,.<>/] character,
        # one uppercase letter, one lowercase letter, and one digit, and password is 8 chars long, override length
        # validation if you want longer password.
        format: [
          { with: %r{[!@#$%^&*()_+\-=\[\]{};':"|,.<>/?]}, message: :must_have_one_special_character },
          { with: /[a-z]/, message: :must_have_one_lowercase_character },
          { with: /[A-Z]/, message: :must_have_one_uppercase_character },
          { with: /[0-9]/, message: :must_have_one_digit },
          { with: /\A.{8,#{ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED}}\z/, message: :must_be_between_8_and_72_characters_long },
        ]
      }.freeze
    end
  end
end
