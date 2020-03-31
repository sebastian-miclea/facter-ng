class OptionsManager
  include Facter::DefaultOptions
  include Facter::ConfigFileOptions


  def initialize
    @options = Options.new
    augment_with_defaults!
    augment_with_config_file_options!
  end

  # this is called by cli, it ca only be called once
  # because the cli executed to user output once
  def conf_file(config_file)
    @options = Options.new
    augment_with_defaults!
    augment_with_config_file_options!(config_file)
  end

  def cli_options(cli_options)
    cli_options.each do |k, v|
      Options.k = v
    end
  end
end


class Options
  @debug
  @trace
  @verbose
  @log_level
  @show_legacy
  @block
  @custom_dir
  @external_dir
  @ruby
  @cli
  @custom_facts
  @blocked_facts
  @ttls
end