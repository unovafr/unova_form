# frozen_string_literal: true

module UnovaForm
  module FieldTypes
    class Password < Base
      INPUT_TYPE = :password

      PASSWORD_LENGTH = 8
      MAX_PASSWORD_LENGTH_ALLOWED = ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED

      CHARS_BY_TYPE = {
        lower: ("a".."z").to_a.freeze,
        upper: ("A".."Z").to_a.freeze,
        digit: ("0".."9").to_a.freeze,
        special: (("!".."/").to_a + (":".."@").to_a + ("[".."`").to_a + ("{".."~").to_a).freeze
      }.freeze

      ALL = (CHARS_BY_TYPE[:lower] + CHARS_BY_TYPE[:upper] + CHARS_BY_TYPE[:digit]).freeze

      VALIDATORS = {
        # classic password validation regex that tests if there is one of [a-z], [A-Z], [0-9] and
        # [!"#$%&'()*+,-.;</:=?>@[\]^_`{|}~] and password is 8 chars long, overridable validation
        format: [
          { with: Regexp.new("[#{CHARS_BY_TYPE[:lower].join}]"), message: :must_have_one_lowercase_character },
          { with: Regexp.new("[#{CHARS_BY_TYPE[:upper].join}]"), message: :must_have_one_uppercase_character },
          { with: Regexp.new("[#{CHARS_BY_TYPE[:digit].join}]"), message: :must_have_one_digit },
          {
            with: Regexp.new("[#{CHARS_BY_TYPE[:special].join.gsub(/[\[\]\-\\]/) { |c| "\\#{c}" }}]"),
            message: :must_have_one_special_character
          },
          { with: /\A.{#{PASSWORD_LENGTH},#{MAX_PASSWORD_LENGTH_ALLOWED}}\z/, message: :must_be_between_8_and_72_characters_long },
        ]
      }.freeze

      def self.generate_random
        str_len = PASSWORD_LENGTH
        # insert random characters from random types until we reach the minimum length - types number
        s = (str_len - (CHARS_BY_TYPE.length - 1)).times.with_object(::String.new) { |_, s| s << (ALL.sample || "") }
        # for each type, insert a random character from this type if there is none in the string
        CHARS_BY_TYPE.keys
          .select { |type| s.each_char.none? { |ch| CHARS_BY_TYPE[type].to_set.include?(ch) } }
          .each { |type| s.insert(rand(s.size + 1), (CHARS_BY_TYPE[type].sample || "")) }
        # insert random characters from all types until we reach the minimum length, to be sure we have enough characters
        (str_len - s.size).times { s << (ALL.sample || "") }
        # final string should have all required types of characters
        s
      end
    end
  end
end
