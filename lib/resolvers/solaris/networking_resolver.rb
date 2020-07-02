require_relative 'ffi/ffi.rb'
require 'ipaddr'
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
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            socket = create_socket(Facter::Resolvers::Solaris::AF_INET)

            interfaces = load_interfaces(socket)
            Socket::close(socket)
            network_interfaces = {}
            interfaces.each do |interface|
              socket = create_socket(interface[:lifr_lifru][:lifru_addr][:ss_family])
              mac = load_mac(socket, interface)
              ip = inet_ntop(interface)
              netmask = load_netmask(socket, interface)
              ipaddr = IPAddr.new(netmask)
              mask_length = ipaddr.to_i.to_s(2).count('1')
              bindings = ::Resolvers::Utils::Networking.build_binding(ip, mask_length)
							#netmask = load_netmask(socket, interface)
							#Socket::close(socket)
							#ipaddr = IPAddr.new(netmask)
							#mask_length = ipaddr.to_i.to_s(2).count('1')
							#socket = create_socket(interface[:lifr_lifru][:lifru_addr][:ss_family])
              network_interfaces[interface[:lifr_name].to_s] = {
                bindings: bindings,
                mac: mac,
                mtu: load_mtu(socket, interface)
              }
              Socket::close(socket)

            end
            @fact_list[:interfaces] = network_interfaces
            @fact_list[fact_name]
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
									netmask_lifreq = Lifreq.new(lifreq.to_ptr)
            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifreq(
                    socket,
                    Facter::Resolvers::Solaris::SIOCGLIFNETMASK,
                    netmask_lifreq
                    )

						if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            else
              inet_ntop(netmask_lifreq)
            end
          end

          def inet_ntop(lifreq)
            sockaddr = Sockaddr.new(lifreq[:lifr_lifru][:lifru_addr].to_ptr)
            sockaddr_in = SockaddrIn.new(sockaddr.to_ptr)
            ip = InAddr.new(sockaddr_in[:sin_addr].to_ptr)

            buffer = FFI::MemoryPointer.new(:char, Facter::Resolvers::Solaris::INET_ADDRSTRLEN)
            Facter::Resolvers::Solaris::Socket::inet_ntop(
              Facter::Resolvers::Solaris::AF_INET,
              ip.to_ptr,
              buffer.to_ptr,
              buffer.size
            )
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
              interfaces << lifreq
              # {name: lifreq[:lifr_name].to_s, fam: lifreq[:lifr_lifru][:lifru_addr][:ss_family] }
            end
            interfaces
          end
        end
      end
    end
  end
end
