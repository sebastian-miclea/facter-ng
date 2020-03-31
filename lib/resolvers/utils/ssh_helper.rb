# frozen_string_literal: true

require 'base64'
require 'digest/sha1'

module Facter
  class SshHelper
    class << self
      SSH_NAME = { 'ssh-dss' => 'dsa', 'ecdsa-sha2-nistp256' => 'ecdsa',
                   'ssh-ed25519' => 'ed25519', 'ssh-rsa' => 'rsa' }.freeze
      SSH_FINGERPRINT = { 'rsa' => 1, 'dsa' => 2, 'ecdsa' => 3, 'ed25519' => 4 }.freeze

      def create_ssh(key_name, key_type, key)
        decoded_key = Base64.decode64(key)
        ssh_fa = SSH_FINGERPRINT[key_name]
        sha1 = "SSHFP #{ssh_fa} 1 #{Digest::SHA1.new.update(decoded_key)}"
        sha256 = "SSHFP #{ssh_fa} 2 #{Digest::SHA2.new.update(decoded_key)}"

        fingerprint = FingerPrint.new(sha1, sha256)
        Ssh.new(fingerprint, key_type, key, key_name)
      end

      def determine_ssh_key_name(key)
        SSH_NAME[key]
      end
    end
  end
end
