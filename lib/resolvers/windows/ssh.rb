# frozen_string_literal: true

module Facter
  module Resolvers
    module Windows
      class Ssh < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        FILE_NAMES = %w[ssh_host_rsa_key.pub ssh_host_dsa_key.pub
                        ssh_host_ecdsa_key.pub ssh_host_ed25519_key.pub].freeze
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { retrieve_info(fact_name) }
          end

          def retrieve_info(fact_name)
            ssh_dir = determine_ssh_dir
            return unless ssh_dir && File.directory?(ssh_dir)

            ssh_list = []

            FILE_NAMES.each do |file_name|
              next unless File.readable?(File.join(ssh_dir, file_name))

              key_type, key = File.read(File.join(ssh_dir, file_name)).split(' ')
              key_name = SshHelper.determine_ssh_key_name(key_type)
              ssh_list << SshHelper.create_ssh(key_name, key_type, key)
            end
            @fact_list[:ssh] = ssh_list
            @fact_list[fact_name]
          end

          def determine_ssh_dir
            progdata_dir = ENV['programdata']

            return if !progdata_dir || progdata_dir.empty?

            File.join(progdata_dir, 'ssh')
          end
        end
      end
    end
  end
end
