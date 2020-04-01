# frozen_string_literal: true

module Facter
  class CacheManager
    def initialize
      @groups = {}
    end

    def cache_dir
      LegacyFacter::Util::Config.facts_cache_dir
    end

    def resolve_facts(searched_facts)
      return searched_facts, [] unless File.directory?(cache_dir)

      facts = []
      searched_facts.each do |fact|
        res = resolve_fact(fact)
        facts << res unless res.nil?
      end
      facts.each do |fact|
        searched_facts.delete_if { |f| f.name == fact.name }
      end
      [searched_facts, facts]
    end

    def cache_facts(resolved_facts)
      unless File.directory?(cache_dir)
        require 'fileutils'
        FileUtils.mkdir_p(cache_dir)
      end

      resolved_facts.each do |fact|
        cache_fact(fact)
      end

      write_cache
    end

    private

    def resolve_fact(searched_fact)
      group_name = Facter::CacheList.instance.get_fact_group(searched_fact.name)
      return nil unless group_name

      return nil unless group_cached?(group_name)

      return nil if check_ttls(group_name).zero?

      data = read_group_json(group_name)
      return nil if data.nil? || data[searched_fact.name].nil?

      create_fact(searched_fact, data[searched_fact.name])
    end

    def create_fact(searched_fact, value)
      resolved_fact = Facter::ResolvedFact.new(searched_fact.name, value, searched_fact.type)
      resolved_fact.user_query = searched_fact.user_query
      resolved_fact.filter_tokens = searched_fact.filter_tokens
      resolved_fact
    end

    def cache_fact(fact)
      group_name = Facter::CacheList.instance.get_fact_group(fact.name)
      return if group_name.nil? || fact.value.nil?

      return unless group_cached?(group_name)

      @groups[group_name] ||= {}
      @groups[group_name][fact.name] = fact.value
    end

    def write_cache
      @groups.each do |group_name, data|
        next if check_ttls(group_name).zero?

        cache_file_name = File.join(cache_dir, group_name)
        File.write(cache_file_name, JSON.pretty_generate(data))
      end
    end

    def read_group_json(group_name)
      return @groups[group_name] if @groups.key?(group_name)

      cache_file_name = File.join(cache_dir, group_name)
      data = nil
      if File.exist?(cache_file_name)
        file = File.read(cache_file_name)
        data = JSON.parse(file)
      end
      @groups[group_name] = data
      data
    end

    def group_cached?(group_name)
      Facter::CacheList.instance.get_group_ttls(group_name) ? true : false
    end

    def check_ttls(group_name)
      ttls = Facter::CacheList.instance.get_group_ttls(group_name)
      return 0 unless ttls

      cache_file_name = File.join(cache_dir, group_name)
      return ttls unless File.exist?(cache_file_name)

      file_time = File.mtime(cache_file_name)
      expire_date = file_time + ttls
      if expire_date < Time.now
        File.delete(cache_file_name)
        return ttls
      end
      expire_date.to_i
    end
  end
end
