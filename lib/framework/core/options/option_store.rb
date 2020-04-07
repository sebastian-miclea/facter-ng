# frozen_string_literal: true

module Facter
  module OptionStore
    DEFAULT_LOG_LEVEL = :warn

    extend self

    attr :debug, :trace, :verbose, :log_level, :show_legacy,
         :block, :custom_dir, :external_dir, :external_facts, :ruby, :cli,
         :custom_facts, :ttls
    attr_accessor :config, :user_query, :blocked_facts, :strict

    # default options
    @debug = false
    @trace = false
    @verbose = false
    @log_level = DEFAULT_LOG_LEVEL
    @show_legacy = true
    @block = true
    @custom_dir = []
    @custom_facts = true
    @external_dir = []
    @external_facts = true
    @ruby = true
    @blocked_facts = []

    def ruby=(bool)
      if bool == true
        @ruby = true
      else
        @custom_facts = false
        @blocked_facts << 'ruby'
      end
    end

    def external_dir=(dirs)
      return unless dirs.any?

      @external_facts = true
      @external_dir = dirs
    end

    def custom_dir=(*dirs)
      return unless dirs.any?

      @custom_facts = true
      @ruby = true
      @custom_dir = [*dirs]
    end

    def debug=(bool)
      if bool == true
        @debug = true
        self.log_level = :debug
      else
        @debug = false
        self.log_level = DEFAULT_LOG_LEVEL
      end
    end

    def verbose=(bool)
      if bool == true
        @verbose = true
        self.log_level = :info
      else
        @verbose = false
        self.log_level = DEFAULT_LOG_LEVEL
      end
    end

    def log_level=(level)
      case level
      when :trace
        @log_level = :debug
        @trace = true
      when :debug
        @log_level = :debug
        @debug = true
      else
        @log_level = level
      end

      Log.level = @log_level
      Facter.trace(@trace)
    end

    def show_legacy=(bool)
      if bool == true
        @show_legacy = bool
        @ruby = true
      else
        @show_legacy = false
        @ruby = Facter::OptionDefaults.ruby
      end
    end

    def cli=(bool)
      @cli = bool
    end
  end
end
