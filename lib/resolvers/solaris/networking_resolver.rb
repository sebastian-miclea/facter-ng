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
	    interfaces.each do |int, fam|
	    	macadress = load_macaddress(int, fam)
	    end
            p interfaces
          end

	  def load_macaddress(interface, family)
            socket = Socket::socket(
              family[:fam],
	      Facter::Resolvers::Solaris::SOCK_DGRAM,
              0
            )
	        arp = Facter::Resolvers::Solaris::Arpreq.new

		ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_arpreq(
		7, 
		Facter::Resolvers::Solaris::SIOCGARP,
		arp)
		binding.pry
	    if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

	  end

          def count_interfaces(socket)

            lifnum = Facter::Resolvers::Solaris::Lifnum.new
            lifnum[:family] = Facter::Resolvers::Solaris::AF_UNSPEC
            lifnum[:flags] = 0
            lifnum[:count] = 0
            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifnum(socket, Facter::Resolvers::Solaris::SIOCGLIFNUM, lifnum)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            lifnum[:count]
          end

          def load_interfaces(socket)
            interface_count  = count_interfaces(socket)

            lifconf = Facter::Resolvers::Solaris::Lifconf.new
            lifconf[:family] = 0
            lifconf[:flags] = 0
            lifconf[:len] = interface_count * 376 # lifreq struct size

            lifconf[:buf] = FFI::MemoryPointer.new(Facter::Resolvers::Solaris::Lifreq, interface_count)

            ioctl = Facter::Resolvers::Solaris::Ioctl::ioctl_lifnum(socket, Facter::Resolvers::Solaris::SIOCGLIFCONF, lifconf)

            if ioctl == -1
              @log.debug("Error! #{FFI::LastError.error}")
            end

            interface_names = {}
            interface_count.times do |i|
              pad = i * Facter::Resolvers::Solaris::Lifreq.size
              lifreq = Facter::Resolvers::Solaris::Lifreq.new(lifconf[:buf] + pad)
	      interface_names[lifreq[:name].to_s] = { fam: lifreq[:lifru][:staddr][:sa_family] }
            end
	    interface_names
          end
        end
      end
    end
  end
end
