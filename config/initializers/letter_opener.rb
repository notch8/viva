# frozen_string_literal: true

# Prevent letter_opener from launching a browser in production
# This is needed when using letter_opener in server environments
if ENV['ENABLE_LETTER_OPENER'].present?
  # Set environment variable to prevent Launchy from trying to open browser
  ENV['LAUNCHY_APPLICATION'] = 'none'
  
  # Also override Launchy as a fallback
  require 'launchy'
  
  module Launchy
    class << self
      alias_method :original_open, :open
      
      def open(*args)
        # Don't launch browser - letter_opener_web will display emails via web interface
        true
      end
    end
  end
end

