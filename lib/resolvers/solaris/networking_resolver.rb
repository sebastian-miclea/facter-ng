require_relative 'ffi/ffi.rb'
require 'pry'
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
              Facter::Resolvers::Solaris::AF_INET,
              Facter::Resolvers::Solaris::SOCK_DGRAM,
              0
            )

            interfaces = load_interfaces(socket)
            #x = Socket::close(socket)
            #p x
            interfaces.each do |int, fam|
              #macadress = load_macaddress(int, fam)
            end
            p interfaces
          end

          def load_macaddress(interface, family)
            socket = Socket::socket(
                  2,
                  Facter::Resolvers::Solaris::SOCK_DGRAM,
                  0
                )

            arp = Facter::Resolvers::Solaris::Arpreq.new
            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_arpreq(
                      7,
                      Facter::Resolvers::Solaris::SIOCGARP,
                      arp
                    )

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end
          end

          def count_interfaces(socket)

            lifnum = Facter::Resolvers::Solaris::Lifnum.new
            lifnum[:lifn_family] = Facter::Resolvers::Solaris::AF_UNSPEC
            lifnum[:lifn_flags] = 0
            lifnum[:lifn_count] = 0
            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifnum(socket, Facter::Resolvers::Solaris::SIOCGLIFNUM, lifnum)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            lifnum[:lifn_count]
          end

          def load_interfaces(socket)
            interface_count  = count_interfaces(socket)

            lifconf = Facter::Resolvers::Solaris::Lifconf.new
            lifconf[:lifc_family] = 0
            lifconf[:lifc_flags] = 0
            lifconf[:lifc_len] = interface_count * 376 # lifreq struct size

            lifconf[:lifc_buf] = FFI::MemoryPointer.new(Facter::Resolvers::Solaris::Lifreq, interface_count)

            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifnum(socket, Facter::Resolvers::Solaris::SIOCGLIFCONF, lifconf)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            interface_names = {}
            interface_count.times do |i|
              pad = i * Facter::Resolvers::Solaris::Lifreq.size
              lifreq = Facter::Resolvers::Solaris::Lifreq.new(lifconf[:buf] + pad)
              binding.pry
              interface_names[lifreq[:lifr_name].to_s] = { fam: lifreq[:lifr_lifru][:addr][:sa_family] }
            end
            interface_names
          end
        end
      end
    end
  end
end
