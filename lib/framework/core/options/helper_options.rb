# frozen_string_literal: true

module Facter
  module HelperOptions
    private

    def augment_with_helper_options!
      no_ruby

      # convert array or string to array
      @options[:external_dir] = [*@options[:external_dir]] unless @options[:external_dir].nil?

      @options[:log_level] = log_level || @options[:log_level].to_sym
      @options[:debug] = true if @options[:log_level] == :debug

      validate_log_level
      external_facts
      custom_facts

      Log.level = @options[:log_level]
      Facter.trace(@options[:trace])
    end

    def no_ruby
      return if @options[:ruby]

      @options[:custom_facts] = false
      @options[:blocked_facts] = ['ruby'].concat(@options[:blocked_facts] || [])
    end

    def external_facts
      # @options[:external_facts] = true if @options[:external_dir].any?
    end

    def custom_facts
      # @options[:ruby] = @options[:custom_facts] = true if @options[:custom_dir].any?
    end

    # def log_level
    #   if @options[:debug] || @options[:log_level] == :trace
    #     :debug
    #   elsif @options[:verbose]
    #     :info
    #   end
    # end

    def validate_log_level
      if @options[:log_level].empty?
        OptionsValidator.write_error_and_exit('the required argument for option'\
                                                            " '--log-level' is missing")
      end
      unless OptionsValidator::LOG_LEVEL.include?(
        @options[:log_level].to_sym
      )
        OptionsValidator.write_error_and_exit("invalid log level #{@options[:log_level]}  : expected none, trace,"\
                                                                                ' debug, info, warn, error, or fatal.')
      end
    end
  end
end
