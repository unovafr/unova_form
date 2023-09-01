module UnovaForm
  module Classes
    # @!attribute [r] fields
    #   @return [Hash{Symbol => UnovaForm::Classes::Field}] fields of the form
    # @!attribute [r] contexts
    #   @return [Array<Symbol>] contexts of the form
    class Form
      attr_reader :fields, :contexts

      ##
      # @param fields [Hash{Symbol => UnovaForm::Classes::Field}] fields of the form
      # @param contexts [Array<Symbol>] contexts of the form
      # @return [void]
      def initialize(fields, contexts)
        @fields = fields
        @contexts = contexts
      end

      # @return [Form]
      def dup
        Form.new(fields.deep_dup, contexts.deep_dup)
      end
    end
  end
end