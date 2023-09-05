# frozen_string_literal: true

module UnovaForm
  # noinspection RubyTooManyMethodsInspection
  class Builder < ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :safe_join, :rails_direct_uploads_url, :capture, :concat, to: :@template

    # @return [Module<UnovaForm::Helpers::InputHelper>]
    def self.input_helper
      @helper ||= UnovaForm::Helpers::InputHelper
      @helper
    end

    # @return [Module<UnovaForm::Helpers::InputHelper>]
    def self.input_helper=(v)
      @helper = v
    end

    include self.input_helper

    # @return [Hash{Symbol => UnovaForm::Classes::Form}]
    def forms
      object.class.forms
    end

    # Add all fields to dom based on stored form with given context
    # For example:
    #   Having a model +User+ with:
    #     def_forms do
    #       form :create do
    #         field :email, UnovaForm::FieldTypes::Email, use_type_validators: true, required: true
    #         field :password, UnovaForm::FieldTypes::Password, required: true
    #       end
    #       form :update do
    #         field :lastname, UnovaForm::FieldTypes::String
    #         field :firstname, UnovaForm::FieldTypes::String
    #         field :email, UnovaForm::FieldTypes::Email, use_type_validators: true
    #         field :phone_number, UnovaForm::FieldTypes::Tel, use_type_validators: true
    #         field :password, UnovaForm::FieldTypes::Password
    #       end
    #     end
    #
    #   You can generate create form with:
    #     <%= uform_for @user do |form| %>
    #       <%= form.fields :create %>
    #     <% end %>
    #
    #   You can generate update form with:
    #     <%= uform_for @user do |form| %>
    #       <%= form.fields :update %>
    #     <% end %>
    #
    #   You also can customize your sructure update form with:
    #     <%= uform_for @user do |form| %>
    #       <div class="custom">
    #         <%= form.fields :update, only: :email %>
    #       </div>
    #       <%= form.fields :update, omit: [:email, :password] %>
    #       <div class="custom">
    #         <%= form.fields :update, only: :password %>
    #       </div>
    #     <% end %>
    #
    #   You can pass data that will be sent to helpers:
    #     <%= uform_for @user do |form| %>
    #       <%= form.fields :update, container_class: "bg-red-500" %>
    #     <% end %>
    #
    #   You can pass field-specific data that will be sent to helpers:
    #     <%= uform_for @user do |form| %>
    #       <%= form.fields :update, options_for: { email: { container_class: "bg-red-500" } } %>
    #     <% end %>
    #
    #   You can disable labels:
    #     <%= uform_for @user do |form| %>
    #       <%= form.fields :update, no_labels: true %>
    #     <% end %>
    #
    # @param [Symbol] validation_context form's context
    # @param [Array<Symbol>, Symbol] omit fields blacklist
    # @param [Array<Symbol>, Symbol] only fields whitelist
    # @param [FalseClass, TrueClass] no_labels disable labels on all fields
    # @param [Hash{Symbol => Hash{Symbol => Object}}] options_for field-specific options ex: { email: { container_class: "bg-res-500" } }
    # @param [Hash] options other options that will be sent to fields and helpers that builds fields see UnovaForm::Helpers::InputHelper
    # @return [String]
    def fields(validation_context = :base, omit: nil, only: nil, no_labels: false, options_for: {}, **options)
      check_form(validation_context)

      forms[validation_context].fields
        .filter_map { |method, field|
          if (omit.nil? || (omit != method && (!omit.is_a?(Array) || omit.exclude?(method)))) &&
            (only.nil? || only == method || (only.is_a?(Array) && only.include?(method)))
            self.current_field = field
            to_r = self.field method, validation_context:, no_label: no_labels, **(options_for[method] ? { **options, **options_for[method] } : options)
            self.current_field = nil
            to_r
          end
        }.join.html_safe
    end

    # @param [Symbol] method
    # @param [Symbol] validation_context form's context
    # @param [Hash] options other options that will be sent to helpers that builds fields and/or override builder attributes
    # @option options [String, NilClass] :label
    # @return [ActionView::Helpers::TagHelper::TagBuilder, ActiveSupport::SafeBuffer]
    def field(method, validation_context: :base, **options)
      check_form(validation_context)

      @field = nil if @current_method != method
      # @type [Symbol] current_method
      @current_method = method

      type = current_tag_type

      attrs = {
        id: current_tag_id,
        name: current_tag_name,
        value: type == :time ? current_value&.strftime("%I:%M:%S") : current_value,
        type:,
        error: current_errors,
        required: current_required?,
        options: current_options,
        placeholder: current_human_name_for(:placeholders),
        **options.except(:no_label, :label)
      }

      label = options[:no_label] ? nil : options[:label] || current_human_name_for

      if attrs[:options].present? && [:checkboxes, :select].include?(attrs[:type].to_sym)
        return select_field label, multiple: multiple?, **attrs
      end

      attrs.delete(:options)

      if attrs[:type] == :file
        return file_field label,
          value: current_file_value&.signed_id,
          value_url: current_file_value_url,
          accept: current_accepted_files&.join(","),
          value_type: current_file_type,
          **attrs.except(:value, :placeholder, :type, :autocomplete)
      elsif attrs[:type] == :checkbox
        return boolean_field label, checked: current_value == true, **attrs.except(:value)
      end

      len_validators = current_field.all_validators[:length]
      num_validators = current_field.all_validators[:numericality]
      # import minimum value from length validator or numericality validator
      min, max =
        if len_validators.is_a?(Hash)
          [
            len_validators[:minimum] || (len_validators[:in] || len_validators[:within])&.first || len_validators[:is],
            len_validators[:maximum] || (len_validators[:in] || len_validators[:within])&.last || len_validators[:is]
          ]
        elsif num_validators.is_a?(Hash)
          [
            num_validators[:greater_than_or_equal_to] || num_validators[:equal_to] || num_validators[:in]&.first || num_validators[:greater_than]&.+(options[:step].try(:to_f) || 1),
            num_validators[:less_than_or_equal_to] || num_validators[:equal_to] || num_validators[:in]&.last || num_validators[:less_than]&.+(options[:step].try(:to_f) || 1)
          ]
        end

      pattern, pattern_messages = manage_format_validator

      if pattern_messages.empty?
        return input_field label, min:, max:, **attrs
      end

      input_field label, pattern: pattern.gsub("\"", "\\\""), min:, max:, data: { pattern_messages: pattern_messages.to_json },
        oninvalid: "for (const [r, m] of Object.entries(JSON.parse(this.dataset.patternMessages))) if (!(new RegExp(r)).test(this.value)){ if(this.validationMessage != m) {this.setCustomValidity(m); this.reportValidity();} return; } if(this.validity.customError){this.setCustomValidity(''); this.reportValidity(); if(this.form && this.form.checkValidity()){this.form.submit()} return;}",
        **attrs
    end

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
      # @type [UnovaForm::Builder] form
      fields_for(rna, *args, &block)
    end

    private
      def get_error_message(method, message)
        return object.errors.generate_message method, message if message.is_a?(Symbol)
        message.to_s
      end

      def convert_regex_to_js(regex)
        regex.inspect.sub('\\A', "^").sub('\\Z', "$").sub('\\z', "$").sub(%r{^/}, "").sub(%r{/[a-z]*$}, "").gsub(/\(\?#.+\)/, "").gsub(/\(\?-\w+:/, "(")
      end

      def manage_format_validator
        format_validators = current_field.all_validators[:format]
        return ["", {}] if format_validators.blank?

        # @type [Hash{String => String}] patternMessages
        pattern_messages = {}

        lookaheads_keys = { with: "?=", without: "?!" }

        to_html_pattern = lambda do |validator|
          r = ""
          lookaheads_keys.each do |key, lookahead|
            if validator[key].present?
              reg = convert_regex_to_js(validator[key])
              pattern_messages[reg] = get_error_message(@current_method, validator[:message])
              r += "(#{lookahead}#{'.*' unless reg.starts_with?('^')}#{reg})"
            end
          end
          r
        end

        # @type [String, NilClass] pattern
        # import and concat patterns from format validators
        pattern = if format_validators.is_a?(Array)
          "#{format_validators.map { |v| to_html_pattern.call(v) }.join}.*"
        elsif format_validators.is_a?(Hash)
          "#{to_html_pattern.call(format_validators)}.*"
        end

        [pattern, pattern_messages]
      end

      # @return [UnovaForm::Classes::Field]
      # noinspection RubyMismatchedReturnType (RETURN TYPE WILL BE CORRECT)
      def current_field
        @field ||= forms[@current_validation_context].fields[@current_method]
        raise Exception.new("model #{object.class} dont have field :#{@current_method} on form :#{validation_context}.") if @field.nil? || !@field

        @field
      end

      # @param [UnovaForm::Classes::Field, NilClass] v
      # @return [UnovaForm::Classes::Field, NilClass]
      def current_field=(v)
        @field = v
      end

      # @return [Hash{Symbol => Object}]
      def model_attributes
        attrs = Hash.new
        object.instance_variables.each do |var|
          str = var.to_s.gsub(/^@/, "")
          if object.respond_to? "#{str}="
            attrs[str.to_sym] = instance_variable_get var
          end
        end
        attrs
      end

      # @return [Object, NilClass]
      def current_value
        resp = nil
        resp = object[@current_method] if object.respond_to?("[]")
        resp = object.try(@current_method) if object.respond_to?(@current_method) || resp.nil?
        return resp if resp

        model_attributes[@current_method]
      end

      # @return [String]
      def current_tag_name
        "#{object_name}[#{@current_method}]"
      end

      # @return [String]
      def current_tag_id
        "#{object_name}[#{@current_method}]".tr("[", "_").delete("]") + "-" + (0...20).map { ("a".."z").to_a[rand(26)] }.join
      end

      # @return [Symbol]
      def current_tag_type
        current_field.type::INPUT_TYPE
      end

      # @return [ActionView::Helpers::TagHelper::TagBuilder, ActiveSupport::SafeBuffer]
      def current_errors
        return unless current_errors?

        object.errors[@current_method].join("<br />").html_safe
      end

      # @return [TrueClass, FalseClass]
      def current_errors?
        object.errors&.key?(@current_method) || false
      end

      # @return [TrueClass, FalseClass]
      def current_required?
        (current_field.required || false) &&
          (!object.respond_to?(:persisted?) || !object.persisted? || ((current_field.required_if_persisted || true) && object.persisted?))
      end

      # @return [Array<Hash{Symbol => String, TrueClass, FalseClass}>, NilClass]
      def current_options
        options = current_field.options
        return nil if options.nil?

        # if lambda has one argument, pass current_value
        return options.call(current_value).map(&:symbolize_keys) if options.is_a?(Proc) && options.arity == 1
        # if lambda has two arguments, pass current_value and object model (if options are dynamic using current model)
        return options.call(current_value, object).map(&:symbolize_keys) if options.is_a?(Proc) && options.arity == 2

        # if lambda has no arguments, selected option will be the current_value
        options = options.call.map(&:symbolize_keys) if options.is_a?(Proc) && options.arity == 0

        return options.map { |h|
          nh = h.deep_dup.symbolize_keys
          if nh[:value] == current_value
            nh[:selected] = true
          else
            nh[:selected] = false
          end
          nh
        } if options.is_a?(Array)
        nil
      end

      # @return [FalseClass, TrueClass]
      def multiple?
        current_field.multiple || false
      end

      # @return [ActiveStorage::Blob]
      def current_file_value
        object.try(@current_method)
      end

      # @return [String]
      def current_file_value_url
        current_file_value&.url || ""
      end

      # @return [Symbol]
      def current_file_type
        type = current_accepted_files
        type ||= current_file_value&.content_type ||
          current_file_value&.blob&.content_type
        type = type[0].to_s if type.is_a?(Array)
        if type.nil?
          case @current_method.to_s
          when /video/, /mp4/, /avi/ then :video
          when /avatar/, /image/, /img/, /picture/, /photo/, /jpg/, /png/, /bitmap/ then :img
          when /sound/, /audio/, /mp3/, /music/, /song/ then :audio
          else
            :other
          end
        elsif type.start_with?("image")
          :img
        elsif type.start_with?("video")
          :video
        elsif type.start_with?("audio")
          :audio
        else
          :other
        end
      end

      # @return [Array<String>, NilClass]
      # noinspection RubyMismatchedReturnType
      def current_accepted_files
        current_field.all_validators.[](:content_type)&.[](:in)
      end

      # @param [Symbol] element
      # @param [Hash] options
      # @return [String]
      def current_human_name_for(element = :attributes, **options)
        defaults = object.class.lookup_ancestors.map do |klass|
          [:"#{object.class.i18n_scope}.#{element}.#{klass.model_name.i18n_key}.#{@current_method}",
            :"#{object.class.i18n_scope}.#{element}.#{klass.model_name.i18n_key.to_s.tr('.', '/')}.#{@current_method}"]
        end.flatten

        defaults << :"#{element}.#{@current_method}"
        defaults << options.delete(:default) if options[:default]
        defaults << @current_method.to_s.humanize if Rails.env.production? # Monkey patch

        options.reverse_merge! count: 1, default: defaults
        I18n.t(defaults.shift, **options).html_safe
      end

      # @param [Symbol] validation_context
      # @return [void]
      def check_form(validation_context)
        # @type [Symbol] current_validation_context
        @current_validation_context = validation_context

        unless object.class.respond_to?(:forms)
          raise Exception.new("model #{object.class} must extend UnovaForm::Concern::HasForm")
        end

        unless forms.key?(validation_context)
          raise Exception.new("model #{object.class} dont have form for :#{validation_context} context.")
        end
      end
  end
end
