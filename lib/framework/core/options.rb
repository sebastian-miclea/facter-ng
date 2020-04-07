# frozen_string_literal: true

module Facter
  module Options
    extend Facter::ConfigFileOptions
    extend Facter::HelperOptions
    extend Facter::OptionStore

    @options = {}

    extend self

    def cli?
      @options[:cli]
    end

    def get
      @options
    end

    def [](key)
      # OptionStore(key, nil)
    end

    def []=(key, value)
      @options[key.to_sym] = value
    end

    def custom_dir?
      @options[:custom_dir] && @options[:custom_facts]
    end

    def custom_dir
      @options[:custom_dir]
    end

    def external_dir?
      @options[:external_dir] && @options[:external_facts]
    end

    def external_dir
      @options[:external_dir]
    end

    def init_from_api
      @options[:cli] = false
      send(:augment_with_config_file_options!)
    end

    def init_from_cli(cli_options = {}, user_query = nil)
      OptionStore.cli = true
      OptionStore.show_legacy = true

      send(:augment_with_config_file_options!, cli_options[:config])
      @options[:user_query] = user_query

      cli_options.each do |key, val|
        val = '' if key == 'log_level' && val == 'log_level'
        OptionStore.send("#{key}=".to_sym, val)
      end

      Facter::OptionsValidator.validate_configs(@options)

      send(:augment_with_helper_options!)
    end

    def reset!
      @options = {}
      augment_with_defaults!
    end
  end
end
