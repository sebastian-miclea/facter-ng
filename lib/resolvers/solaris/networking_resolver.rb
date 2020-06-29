require_relative 'ffi/ffi.rb'

module Facter
  module Resolvers
    module Solaris
      class Networking2 < BaseResolver
        @log = Facter::Log.new(self)
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            socket = Socket::socket(
              Facter::Resolvers::Solaris::FFI::AF_INET,
              Facter::Resolvers::Solaris::FFI::SOCK_DGRAM,
              0
            )

            interfaces = load_interfaces(socket)
            p interfaces
          end

          def count_interfaces(socket)

            lifnum = Facter::Resolvers::Solaris::FFI::Lifnum.new
            lifnum[:family] = Facter::Resolvers::Solaris::FFI::AF_UNSPEC
            lifnum[:flags] = 0
            lifnum[:count] = 0

            ioctl = Facter::Resolvers::Solaris::FFI::Ioctl::ioctl(socket, Facter::Resolvers::Solaris::FFI::SIOCGLIFNUM, lifnum)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            lifnum[:count]
          end

          def load_interfaces(socket)
            interface_count  = count_interfaces(socket)

            lifconf = Facter::Resolvers::Solaris::FFI::Lifconf.new
            lifconf[:family] = 0
            lifconf[:flags] = 0
            lifconf[:len] = interface_count * 376 # lifreq struct size

            lifconf[:buf] = FFI::MemoryPointer.new(Facter::Resolvers::Solaris::FFi::Lifreq, interface_count)

            ioctl = Facter::Resolvers::Solaris::FFI::Ioctl::ioctl(socket, Facter::Resolvers::Solaris::FFI::SIOCGLIFCONF, lifconf)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            interface_names = []
            interface_count.times do |i|
              pad = i * Facter::Resolvers::Solaris::FFI::Lifreq.size
              lifreq = Facter::Resolvers::Solaris::FFI::Lifreq.new(lifconf[:buf] + pad)
              interface_names << lifreq[:name].to_s
            end
          end
        end
      end
    end
  end
end
