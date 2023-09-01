# frozen_string_literal: true

module UnovaForm
  module Helpers
    module FormHelper
      ##
      # Generate form using UnovaForm::Builder, using rails built-in form_for
      # @see #form_for
      # @see UnovaForm::Builder
      #
      # Example:
      #   form_for @model do |form|
      #     form.kind_of?(UnovaForm::Builder)  => false (if not the default form builder)
      #   end
      #
      #   uform_for @model do |form|
      #     form.kind_of?(UnovaForm::Builder)  => true
      #   end
      #
      # @param [Unknown] rna record or name or array (model or attribute)
      # @param [Array] args
      # @yield [form] Build your form using UnovaForm::Builder
      # @yieldparam [UnovaForm::Builder] form Builder with UnovaForm::Builder. you still can use base rails features
      # @return [ActionView::Helpers::TagHelper::TagBuilder, ActiveSupport::SafeBuffer]
      def uform_for(rna, *args, &block)
        override_form_builder(args)
        # @type [UnovaForm::Builder] form
        form_for(rna, *args, &block)
      end

      ##
      # Generate sub-form using UnovaForm::Builder, using rails built-in fields_for
      # @see #fields_for
      # @see UnovaForm::Builder
      # Example:
      #   parent_form.ufields_for @model.attribute_model do |form|
      #     form.kind_of?(UnovaForm::Builder)  => false (if not the default form builder)
      #   end
      #
      #   parent_form.ufields_for @model.attribute_model do |form|
      #     form.kind_of?(UnovaForm::Builder)  => true
      #   end
      #
      # @param [Unknown] rna record or name or array (model or attribute)
      # @param [Array] args
      # @yield [form] Build your form using UnovaForm::Builder
      # @yieldparam [UnovaForm::Builder] form Builder with UnovaForm::Builder. you still can use base rails features
      # @return [ActionView::Helpers::TagHelper::TagBuilder, ActiveSupport::SafeBuffer]
      def ufields_for(rna, *args, &block)
        override_form_builder(args)
        # @type [UnovaForm::Builder] form
        fields_for(rna, *args, &block)
      end

      private
        ##
        # Overrides form builder on args of used helper with UnovaForm::Builder
        # if it's not the default one used on controller or config
        #
        # @param [Array] args
        # @return [void]
        def override_form_builder(args)
          return unless ActionView::Base.default_form_builder != UnovaForm::Builder &&
                        controller.default_form_builder != UnovaForm::Builder

          args.last[:builder] = UnovaForm::Builder if args.last.is_a?(Hash)
          args << { builder: UnovaForm::Builder } unless args.last.is_a?(Hash)
        end
    end
  end
end
