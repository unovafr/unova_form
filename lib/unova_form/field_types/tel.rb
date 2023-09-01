module UnovaForm
  module FieldTypes
    class Tel < Base
      INPUT_TYPE = :tel

      VALIDATORS = {
        # classic french phone number that accepts +33XXXXXXXXX or 0XXXXXXXXX, one or more X can be omitted
        format: { with: /\A((?:\+|00)[17][ -|]?|(?:\+|00)[1-9]\d{0,2}[ -|]?|(?:\+|00)1-\d{3}[ -|]?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:([ -|][0-9]{2}){4}|((?:[0-9]{2}){4})|([ -|][0-9]{3}[ -|][0-9]{4})|([0-9]{7}))\z/, message: :invalid_tel_format }
      }.freeze
    end
  end
end