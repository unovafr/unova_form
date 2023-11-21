# frozen_string_literal: true

require "rails/generators/named_base"

class PromptError < StandardError; end

class UnovaForm::AssetsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__ || __FILE__.split("/")[0...-1].join("/"))

  def generate_asset
    raise PromptError, "Invalid asset type: #{asset_type}, must be one of #{allowed_asset_types.join(', ')}" unless allowed_asset_types.include?(asset_type)
    stylesheets if asset_type.in?(%w[css scss styles stylesheets])
    javascripts if asset_type.in?(%w[js javascripts])

  rescue PromptError => e
    say e.message
  end

  private
    def allowed_asset_types = %w[css scss styles stylesheets js javascripts]
    def asset_type = name

    def default_stylesheet_dests = %w[app/assets/stylesheets app/frontend/stylesheets]
    def existing_stylesheet_dest
      default_stylesheet_dests.find { |d| File.directory?(d) }
    end
    def allowed_stylesheet_schemas = %w[css scss sass]
    def allowed_stylesheet_frameworks = %w[vanilla tailwind]

    def default_javascript_dests = %w[app/javascript app/assets/javascript app/javascripts app/assets/javascripts app/frontend/javascripts]
    def existing_javascript_dest
      default_javascript_dests.find { |d| File.directory?(d) }
    end
    def allowed_javascript_schemas = %w[js ts]
    def allowed_javascript_frameworks = %w[stimulus]

    def css_theme_from_framework(framework)
      @theme = {}
      case framework
        when "tailwind"
          @theme[:label_color] = "text-gray-700"
          @theme[:label_font_size] = "text-sm"
          @theme[:label_font_weight] = "font-normal"
          @theme[:label_font_family] = "font-sans"
          @theme[:label_input_error_gap] = "gap-1"
          @theme[:input_border_color] = "border-gray-300"
          @theme[:input_border_width] = "border"
          @theme[:input_border_radius] = "rounded-md"
          @theme[:input_padding] = "px-3 py-2"
          @theme[:input_color] = "text-gray-900"
          @theme[:input_font_size] = "text-base"
          @theme[:input_font_weight] = "font-normal"
          @theme[:input_font_family] = "font-sans"
          @theme[:input_background_color] = "bg-white"
          @theme[:input_placeholder_color] = "placeholder-gray-500"
          @theme[:input_focus_border_color] = "focus:border-blue-500"
          @theme[:error_color] = "text-red-500"
          @theme[:error_font_size] = "text-sm"
          @theme[:error_font_weight] = "font-normal"
          @theme[:error_font_family] = "font-sans"
          @theme[:error_margin_top] = "mt-1"
          @theme[:error_margin_bottom] = "mb-1"
          @theme[:checkbox_color] = "text-blue-500"
          @theme[:checkbox_size] = "h-4 w-4"
          @theme[:checkbox_border_color] = "border-gray-300"
          @theme[:checkbox_border_width] = "border"
          @theme[:checkbox_border_radius] = "rounded"
          @theme[:radio_color] = "text-blue-500"
          @theme[:radio_size] = "h-4 w-4"
          @theme[:radio_border_color] = "border-gray-300"
          @theme[:radio_border_width] = "border"
          @theme[:radio_border_radius] = "rounded-full"
          @theme[:icon_text_size] = "text-lg"
          @theme[:icon_size] = "h-5 w-5"
          @theme[:icon_left_pos] = "left-2"
          @theme[:icon_right_pos] = "right-2"
          @theme[:input_icon_right_padding] = "pr-8"
          @theme[:input_icon_left_padding] = "pl-8"
        else
          @theme[:label_color] = "#000000"
          @theme[:label_font_size] = "1rem"
          @theme[:label_font_weight] = "400"
          @theme[:label_font_family] = "sans-serif"
          @theme[:label_input_error_gap] = "0.25rem"
          @theme[:input_border_color] = "#000000"
          @theme[:input_border_width] = "1px"
          @theme[:input_border_radius] = "0.25rem"
          @theme[:input_padding] = "0.375rem 0.75rem"
          @theme[:input_color] = "#000000"
          @theme[:input_font_size] = "1rem"
          @theme[:input_font_weight] = "400"
          @theme[:input_font_family] = "sans-serif"
          @theme[:input_background_color] = "#ffffff"
          @theme[:input_placeholder_color] = "#6c757d"
          @theme[:input_focus_border_color] = "#000000"
          @theme[:error_color] = "#dc3545"
          @theme[:error_font_size] = "0.875rem"
          @theme[:error_font_weight] = "400"
          @theme[:error_font_family] = "sans-serif"
          @theme[:error_margin_top] = "0.25rem"
          @theme[:error_margin_bottom] = "0.25rem"
          @theme[:checkbox_color] = "#000000"
          @theme[:checkbox_size] = "1rem"
          @theme[:checkbox_border_color] = "#000000"
          @theme[:checkbox_border_width] = "1px"
          @theme[:checkbox_border_radius] = "0.25rem"
          @theme[:radio_color] = "#000000"
          @theme[:radio_size] = "1rem"
          @theme[:radio_border_color] = "#000000"
          @theme[:radio_border_width] = "1px"
          @theme[:radio_border_radius] = "50%"
          @theme[:icon_text_size] = "1.25rem"
          @theme[:icon_size] = "1.25rem"
          @theme[:icon_left_pos] = "0.5rem"
          @theme[:icon_right_pos] = "0.5rem"
          @theme[:input_icon_right_padding] = "2rem"
          @theme[:input_icon_left_padding] = "2rem"
      end
      @theme
    end

    def comment_variable_extract(source, var_name) = source.match(/\/[*\/]\s*#{var_name}:\s*(?<value>[\S ]*?)\s*(?:\s\*\/)?\n/)&.named_captures&.[]("value")

    def try_parse_old_theme(destination, schema, framework)
      path = "#{destination}/unova_form.#{schema}"
      return unless File.exist?(path)

      # theme json will be on first line of file, framework will be on second line
      file = File.open(path)
      str = file.readline
      str_framework_used = file.readline
      file.close

      # check if framework is the same
      throw "" unless comment_variable_extract(str_framework_used, "framework_used") == framework

      json_var = comment_variable_extract(str, "theme_used")
      return unless json_var.present?
      json = JSON.parse(json_var).symbolize_keys

      # check if json is valid must be a hash, and all keys must be in @theme (which is the default theme at this point)
      return unless json.is_a?(Hash) && json.all? { |k, _| @theme.key?(k) }

      say "Found existing theme on your old stylesheet, using it as default theme."
      # set @theme to json
      @theme = json
    rescue
      css_theme_from_framework(framework)
    end

    def try_autodetect_framework(frameworks)
      framework_tr = nil
      frameworks.each do |framework|
        framework_tr = framework if case framework
          # tailwind must have a config file to work properly
          when "tailwind" then File.exist?(Rails.root.join("config", "tailwind.config.js")) ||
            File.exist?(Rails.root.join("tailwind.config.js"))
          # to know il stimulus is installed, we want to check if stimulus is mentioned in package.json, or importmap.rb
          when "stimulus" then File.exist?(Rails.root.join("package.json")) && File.read(Rails.root.join("package.json")).include?("@hotwired/stimulus") ||
            File.exist?(Rails.root.join("config", "importmap.rb")) && File.read(Rails.root.join("config", "importmap.rb")).include?("@hotwired/stimulus")
          else nil
        end
      end
      if framework_tr.present?
        framework_tr = nil if yes?("Autodetected framework: #{framework_tr}. Do you want to change it? (y/n) |")
      end
      framework_tr
    end

    def try_autodetect_schema(destination, filename, schemas)
      schema_tr = nil
      schemas.each do |schema|
        schema_tr = schema if File.exist?("#{destination}/#{filename}.#{schema}")
      end
      if schema_tr.present?
        schema_tr = nil if yes?("Autodetected schema: #{schema_tr}. Do you want to change it? (y/n) |")
      end
      schema_tr
    end

    def stylesheets
      # ask for destination
      destination = existing_stylesheet_dest
      while destination.nil?
        destination = ask("Cannot find a valid destination, (tested: #{default_stylesheet_dests.join(', ')}), please enter a valid destination for your stylesheet files:")
        destination = nil unless File.directory?(destination)
      end

      # ask for schema
      schema = try_autodetect_schema(destination, "application", allowed_stylesheet_schemas)
      schema ||= try_autodetect_schema(destination, "unova_form", allowed_stylesheet_schemas)
      while schema.nil?
        schema = ask("What stylesheet schema do you want to use? (#{allowed_stylesheet_schemas.join(', ')}) default: #{allowed_stylesheet_schemas.first}")
        schema = schema.downcase.strip
        schema = allowed_stylesheet_schemas.first if schema.blank?
        schema = nil unless allowed_stylesheet_schemas.include?(schema)
      end

      # ask for framework
      framework = try_autodetect_framework(allowed_stylesheet_frameworks)
      while framework.nil?
        framework = ask("What framework do you want to use? (#{allowed_stylesheet_frameworks.join(', ')}) default: #{allowed_stylesheet_frameworks.first}")
        framework = framework.downcase.strip
        framework = allowed_stylesheet_frameworks.first if framework.blank?
        framework = nil unless allowed_stylesheet_frameworks.include?(framework)
      end


      # generate default theme
      css_theme_from_framework(framework)
      # try pick theme from existing stylesheet
      try_parse_old_theme(destination, schema, framework)

      # say @theme and ask if want to edit
      say "Here is your theme:"
      @theme.each { |k, v| say "   #{k}: #{v}" }
      if yes?("Do you want to edit it? (y/n) |")
        # ask if step by step is wanted or not
        if yes?("Do you want to edit it step by step? (y/n), if you answer no, you will be asked if you want to edit individual values.")
          @theme.each do |k, v|
            ans = ask("#{k}: (#{v}) |")
            @theme[k] = ans if ans.present?
          end
        else
          # ask if want to edit individual values
          if yes?("Do you want to edit any @theme value?")
            el_editing = "notBlank"
            while el_editing.present?
              # ask for element to edit
              el_editing = ask("What element do you want to edit? (#{@theme.keys.join(', ')}) leave blank to stop editing")
              continue if el_editing.blank?
              el_editing = el_editing.downcase.strip
              continue unless @theme.key?(el_editing)
              @theme[el_editing] = ask("#{el_editing}: (#{@theme[el_editing]}) |") if @theme.key?(el_editing)
            end
          end
        end
      end

      say "Generating stylesheet with schema: #{schema}, framework: #{framework} on destination: #{destination}"

      @framework = framework
      case framework
        when "tailwind"
          template "css/tailwind/tailwind.#{schema}.erb", "#{destination}/unova_form.#{schema}"
        else
          template "css/vanilla/vanilla.#{schema}.erb", "#{destination}/unova_form.#{schema}"
      end

      if yes?("Do you want append a stylesheet import to your application css file? (y/n) |")
        say "Stylesheet generated, trying to add it to your application css file"
        application_css = "#{destination}/application.#{schema}"
        until File.exist?(application_css)
          application_css = ask("Cannot find #{application_css}, please enter the relative path to your application css file:")
        end

        case application_css.split(".").last
          when "scss"
            prepend_to_file application_css, "@import 'unova_form';\n"
          when "sass"
            prepend_to_file application_css, "@import 'unova_form'\n"
          else
            prepend_to_file application_css, "@import 'unova_form.css';\n"
        end
      end

      say ""
      say "=================================================================="
      say "                        Impotant notes:"
      say "  It's not recommended to move the unova_form stylesheet, as if"
      say "any update is made to the gem, it will be harder to re-generate it"
      say "       and old theme used will not be pulled into generator."
      say "   Feel free to regenerate it if you want to change the theme."
      say "Please don't edit it directly, as it will be overwritten on update"
      say "   prefer importing it in another css and override rules there."
      say "=================================================================="
    end

    def javascripts
      # ask for destination
      destination = existing_javascript_dest
      while destination.nil?
        destination = ask("Cannot find a valid destination, (tested: #{default_javascript_dests.join(', ')}), please enter a valid destination for your javascript files:")
        destination = nil unless File.exist?(destination)
      end

      # ask for schema
      schema = try_autodetect_schema(destination, "application", allowed_javascript_schemas)
      while schema.nil?
        schema = ask("What javascript schema do you want to use? (#{allowed_javascript_schemas.join(', ')}) default: #{allowed_javascript_schemas.first}")
        schema = schema.downcase.strip
        schema = allowed_javascript_schemas.first if schema.blank?
        schema = nil unless allowed_javascript_schemas.include?(schema)
      end

      # ask for framework
      framework = try_autodetect_framework(allowed_javascript_frameworks)
      while framework.nil?
        framework = ask("What framework do you want to use? (#{allowed_javascript_frameworks.join(', ')}) default: #{allowed_javascript_frameworks.first}")
        framework = framework.downcase.strip
        framework = allowed_javascript_frameworks.first if framework.blank?
        framework = nil unless allowed_javascript_frameworks.include?(framework)
      end

      say "Generating javascript with schema: #{schema}, framework: #{framework} on destination: #{destination}"

      # templates will be located on lib/generators/unova_form/assets/templates/js/{schema}/*
      case framework
        when "stimulus"
          Dir.glob(File.expand_path("templates/js/stimulus/#{schema}/controllers/*", __dir__)).each do |template|
            template template, "#{destination}/controllers/#{File.basename(template)}"
          end
          Dir.glob(File.expand_path("templates/js/stimulus/#{schema}/lib/*", __dir__)).each do |template|
            template template, "#{destination}/lib/#{File.basename(template)}"
          end
        else
          Dir.glob(File.expand_path("templates/js/vanilla/#{schema}/controllers/*", __dir__)).each do |template|
            template template, "#{destination}/#{File.basename(template)}"
          end
          Dir.glob(File.expand_path("templates/js/vanilla/#{schema}/lib/*", __dir__)).each do |template|
            template template, "#{destination}/lib/#{File.basename(template)}"
          end
      end

      if framework != "stimulus"
        say "Javascript generated, trying to add it to your application js file"

        application_js = "#{destination}/application.#{schema}"
        until File.exist?(application_js)
          application_js = ask("Cannot find #{application_js}, please enter the relative path to your application js file:")
        end

        case application_js.split(".").last
          when "ts"
            append_to_file application_js, "import 'unova_form';\n"
          else
            append_to_file application_js, "//= require unova_form\n"
        end
      else
        say ""
        say "=============================================================="
        say "                      Impotant notes:"
        say "You need stimulus and stimulus-use to be installed on your app"
        say "JS code use modern javascript, so you may need to transpile it"
        say "=============================================================="
      end
    end
end
