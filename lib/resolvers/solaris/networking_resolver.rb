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
            socket = create_socket(Facter::Resolvers::Solaris::AF_INET)

            interfaces = load_interfaces(socket)
            Socket::close(socket)

            interfaces.each do |interface|
              socket = create_socket(lifreq[:lifr_lifru][:lifru_addr][:ss_family])
              @fact_list[interface[:lifr_name]] = {
                mac: load_mac(socket, lifreq),
                mtu: load_mtu(socket, lifreq),
                bindings: {
                  netmask: load_netmask(socket, lifreq)
                }
              }
              Socket::close(socket)
            end


          end

          def create_socket(family)
            Socket::socket(
              family,
              Facter::Resolvers::Solaris::SOCK_DGRAM,
              0
            )
          end


          def load_mac(socket, lifreq)
            arp = Arpreq.new
            arp_addr = SockaddrIn.new(arp[:arp_pa].to_ptr)
            arp_addr[:sin_addr][:s_addr] = SockaddrIn.new(lifreq[:lifr_lifru][:lifru_addr].to_ptr)[:sin_addr][:s_addr]

            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_arpreq(
                      socket,
                      Facter::Resolvers::Solaris::SIOCGARP,
                      arp
                    )
            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            arp[:arp_ha][:sa_data].entries[0,6].map { |s| s.to_s(16).rjust(2, '0') }.join ':'
          end

          def load_mtu(socket, lifreq)
            socket = Socket::socket(
              res[:fam],
              Facter::Resolvers::Solaris::SOCK_DGRAM,
              0
            )

            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifreq(
              socket,
              Facter::Resolvers::Solaris::SIOCGLIFMTU,
              lifreq
            )

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            lifreq[:lifr_lifru][:lifru_metric]
          end

          def load_netmask(socket, lifreq)
            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifreq(
                    socket,
                    Facter::Resolvers::Solaris::SIOCGLIFNETMASK,
                    lifreq
                    )

            sockaddr = Sockaddr.new(lifreq[:lifr_lifru][:lifru_addr].to_ptr)
            sockaddr_in = SockaddrIn.new(sockaddr.to_ptr)
            ip = InAddr.new(sockaddr_in[:sin_addr].to_ptr)

            buffer = FFI::MemoryPointer.new(:char, Facter::Resolvers::Solaris::INET_ADDRSTRLEN)
            inet_ntop = Facter::Resolvers::Solaris::Socket::inet_ntop(
              Facter::Resolvers::Solaris::AF_INET,
              ip.to_ptr,
              buffer.to_ptr,
              buffer.size
            )

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            inet_ntop
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
            lifconf[:lifc_len] = interface_count * Facter::Resolvers::Solaris::Lifreq.size # 376 lifreq struct size

            lifconf[:lifc_buf] = FFI::MemoryPointer.new(Facter::Resolvers::Solaris::Lifreq, interface_count)

            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifnum(socket, Facter::Resolvers::Solaris::SIOCGLIFCONF, lifconf)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            interfaces = []
            interface_count.times do |i|
              pad = i * Facter::Resolvers::Solaris::Lifreq.size
              lifreq = Facter::Resolvers::Solaris::Lifreq.new(lifconf[:lifc_buf] + pad)
              interfaces < lifreq
              # {name: lifreq[:lifr_name].to_s, fam: lifreq[:lifr_lifru][:lifru_addr][:ss_family] }
            end
            interfaces
          end
        end
      end
    end
  end
end
