# frozen_string_literal: true

module DeprecationToolkit
  module Warning
    extend self

    def deprecation_triggered?(str)
      if DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning =~ str }
        ActiveSupport::Deprecation.warn(str)
        true
      end
    end
  end
end

# Warning is a new feature in ruby 2.5
module Warning
  def warn(str)
    super unless DeprecationToolkit::Warning.deprecation_triggered?(str)
  end
end

# Support for version older < 2.5
# Note that the `Warning` module exists in Ruby 2.4 but has a bug https://bugs.ruby-lang.org/issues/12944
if RUBY_VERSION < '2.5.0' && RUBY_ENGINE == 'ruby'
  module Kernel
    alias_method :__original_warn, :warn

    def warn(*messages)
      message = messages.join("\n")
      message += "\n" unless message.end_with?("\n")

      __original_warn(messages) unless DeprecationToolkit::Warning.deprecation_triggered?(message)
    end
  end
end
