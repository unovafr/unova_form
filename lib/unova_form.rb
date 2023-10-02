# frozen_string_literal: true
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

module UnovaForm
  class Error < StandardError; end
  # Your code goes here...
  ActionView::Base.include UnovaForm::Helpers::FormHelper
end
