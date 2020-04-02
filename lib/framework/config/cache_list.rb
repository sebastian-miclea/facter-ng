# frozen_string_literal: true

module Facter
  class CacheList
    include Singleton

    attr_reader :cache_groups, :groups_ttls

    def initialize(block_list_path = nil)
      @block_groups_file_path = block_list_path || File.join(ROOT_DIR, 'fact_groups.conf')
      load_cache_groups
    end

    # Get the group name a fact is part of
    def get_fact_group(fact_name)
      @cache_groups.detect { |k, v| break k if Array(v).find { |f| fact_name.match?(/^#{f}.*/) } }
    end

    # Get config ttls for a given group
    def get_group_ttls(group_name)
      return unless (ttls = @groups_ttls.find { |g| g[group_name] })

      ttls_to_seconds(ttls[group_name])
    end

    private

    def load_cache_groups
      @cache_groups = Facter::GroupList.instance.groups
      options = Options.instance
      @groups_ttls = ConfigReader.new(options[:config]).ttls || {}
    end

    def ttls_to_seconds(ttls)
      duration, unit = ttls.split(' ', 2)
      time = duration.to_i
      case unit
      when 'seconds'
        return time
      when 'minutes'
        return time * 60
      when 'hours'
        return time * 60 * 60
      when 'days'
        return time * 60 * 60 * 24
      end
    end
  end
end
