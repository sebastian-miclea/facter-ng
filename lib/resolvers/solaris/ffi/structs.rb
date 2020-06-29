module Facter
  module Resolvers
    module Solaris

        class SockaddrStorage < FFI::Struct
          layout	:sa_family, :uint16,
	    						:pad, [:char, 240]
        end

	class Sockaddr < FFI::Struct
          layout(
            :sa_family, :sa_family_t,
            :sa_data, [:char, 14]
          )
	end

        class Lifnum < FFI::Struct
                layout :family, :uint,
                        :flags, :int,
                        :count, :int
        end

	class Arpreq < FFI::Struct
		layout 	:arp_pa, Sockaddr,
						:arp_ha, Sockaddr,
						:arp_flags, :int

	end

        class Lifru1 < FFI::Union
          layout :addrlen, :int,
           :ppa, :size_t
        end

        class Lifru < FFI::Union
          layout :addr, SockaddrStorage,
           :dstaddr, SockaddrStorage,
           :broad_addr, SockaddrStorage
          # :token, Sockaddr,
          # :index, :int,
          # :flags, :uint64_t,
          #  :metric, :int
          # :mtu, :uint_t

        end

        class Lifreq < FFI::Struct
          layout  :name, [:char, 32],
		  :lifru1, Lifru1,
		  :lifru, Lifru,
            :pad, [:char, 96]
        end

        class Lifconf < FFI::Struct
          layout :family, :uint,
            :flags, :int,
            :len, :int,
          # :buf, :caddr_t,
            :buf, :pointer
          # :lifreq, Lifreq

        end

        class Lifcu < FFI::Union
          layout :lifcu_buf, :caddr_t,
            :lifreq, Lifreq
        end
    end
  end
end
