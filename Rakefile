# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

task default: :spec


if Bundler.rubygems.find_name('github_changelog_generator').any?
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new  :changelog do |config|

    raise "Set CHANGELOG_GITHUB_TOKEN environment variable eg 'export CHANGELOG_GITHUB_TOKEN=valid_token_here'" if Rake.application.top_level_tasks.include?('changelog') && ENV['CHANGELOG_GITHUB_TOKEN'].nil?
    config.user = 'puppetlabs'
    config.project = 'facter-ng'
    config.since_tag = File.read('VERSION').strip
    config.exclude_labels = ['maintenance']
    config.header = "# Change log\n\nAll notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org)."
    config.add_pr_wo_labels = true
    config.issues = false
    config.max_issues = 100
    config.header = ''
    config.base = 'CHANGELOG.md'
    config.merge_prefix = '### UNCATEGORIZED PRS; GO LABEL THEM'
    config.configure_sections = {
      "Changed": {
        "prefix": '### Changed',
        "labels": ['backwards-incompatible']
      },
      "Added": {
        "prefix": '### Added',
        "labels": ['feature']
      },
      "Fixed": {
        "prefix": '### Fixed',
        "labels": ['bugfix']
      }
    }
  end
  else
    desc 'Generate a Changelog from GitHub'
    task :changelog do
      raise <<EOM
The changelog tasks depends on github_changelog_generator gem.
Please install github_changelog_generator:
---
Gemfile:
  optional:
    ':development':
      - gem: 'github_changelog_generator'
        condition: "Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.2.2')"
EOM
  end
end
