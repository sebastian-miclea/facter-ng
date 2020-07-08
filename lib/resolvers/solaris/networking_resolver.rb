# frozen_string_literal: true

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

        BINDINGS_KEY = {
          AF_INET => 'bindings',
          AF_INET6 => 'bindings6'
        }.freeze

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { read_facts(fact_name) }
          end

          def read_facts(fact_name)
            interfaces = {}
            lifreqs = load_interfaces

            lifreqs.each do |lifreq|
              socket = create_socket(lifreq.ss_family)

              interfaces[lifreq.name] ||= {}
              interfaces[lifreq.name][:mac] = load_mac(socket, lifreq)

              bindings_key, bindings = add_bindings(socket, lifreq)

              interfaces[lifreq.name].merge(bindings_key => bindings)

              interfaces[lifreq.name][:mtu] = load_mtu(socket, lifreq)
              Socket.close(socket)
            end

            @fact_list[:interfaces] = interfaces
            @fact_list[fact_name]
          end

          def create_socket(address_family)
            Socket.socket(address_family, SOCK_DGRAM, 0)
          end

          def load_mac(socket, lifreq)
            arp = Arpreq.new
            arp_addr = SockaddrIn.new(arp[:arp_pa].to_ptr)
            arp_addr[:sin_addr][:s_addr] = SockaddrIn.new(lifreq.lifru_addr.to_ptr).s_addr

            ioctl = Ioctl.ioctl(socket, SIOCGARP, arp)

            @log.debug("Error! #{FFI::LastError.error}") if ioctl == -1

            mac = arp.sa_data_to_mac
            mac if mac.count('0') < 12
          end

          def load_mtu(socket, lifreq)
            ioctl = Ioctl.ioctl(socket, SIOCGLIFMTU, lifreq)

            @log.debug("Error! #{FFI::LastError.error}") if ioctl == -1

            lifreq[:lifr_lifru][:lifru_metric]
          end

          def load_netmask(socket, lifreq)
            netmask_lifreq = Lifreq.new(lifreq.to_ptr)

            ioctl = Ioctl.ioctl(socket, SIOCGLIFNETMASK, netmask_lifreq)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            else
              netmask = inet_ntop(netmask_lifreq, lifreq.ss_family)
              [netmask, calculate_mask_length(netmask)]
            end
          end

          def inet_ntop(lifreq, ss_family)
            sockaddr = Sockaddr.new(lifreq[:lifr_lifru][:lifru_addr].to_ptr)
            sockaddr_in = SockaddrIn.new(sockaddr.to_ptr)
            ip = InAddr.new(sockaddr_in[:sin_addr].to_ptr)
            buffer_size = INET_ADDRSTRLEN
            buffer_size = INET6_ADDRSTRLEN if ss_family == AF_INET6
            buffer = FFI::MemoryPointer.new(:char, buffer_size)

            Socket.inet_ntop(ss_family, ip.to_ptr, buffer.to_ptr, buffer.size)
          end

          def count_interfaces(socket)
            lifnum = Lifnum.new
            lifnum[:lifn_family] = AF_UNSPEC
            lifnum[:lifn_flags] = 0
            lifnum[:lifn_count] = 0

            ioctl = Ioctl.ioctl(socket, SIOCGLIFNUM, lifnum)

            @log.debug("Error! #{FFI::LastError.error}") if ioctl == -1

            lifnum[:lifn_count]
          end

          def load_interfaces
            socket = create_socket(AF_INET)

            interface_count = count_interfaces(socket)

            lifconf = Lifconf.new
            lifconf[:lifc_family] = 0
            lifconf[:lifc_flags] = 0
            lifconf[:lifc_len] = interface_count * Lifreq.size
            lifconf[:lifc_buf] = FFI::MemoryPointer.new(Lifreq, interface_count)

            ioctl = Ioctl.ioctl(socket, SIOCGLIFCONF, lifconf)

            @log.debug("Error! #{FFI::LastError.error}") if ioctl == -1

            interfaces = []
            interface_count.times do |i|
              interfaces << Lifreq.new(lifconf[:lifc_buf] + (i * Lifreq.size))
            end

            Socket.close(socket)
            interfaces
          end

          def add_bindings(socket, lifreq)
            ip = inet_ntop(lifreq, lifreq.ss_family)
            _netmask, netmask_length = load_netmask(socket, lifreq)

            bindings = ::Resolvers::Utils::Networking.build_binding(ip, netmask_length)

            bindings_key = BINDINGS_KEY[lifreq.ss_family]

            [bindings_key, bindings]
          end

          def calculate_mask_length(netmask)
            ipaddr = IPAddr.new(netmask)
            ipaddr.to_i.to_s(2).count('1')
          end

          def with_socket(&block); end
        end
      end
    end
  end
end
