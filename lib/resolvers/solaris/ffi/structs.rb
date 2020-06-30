module Facter
  module Resolvers
    module Solaris

      class SockaddrStorage < FFI::Struct
        layout  :ss_family, :int16,
                :pad, [:char, 254]
      end

      class Sockaddr < FFI::Struct
        layout  :sa_family, :sa_family_t,
                :sa_data, [:uchar, 14]

      end

      class Lifnum < FFI::Struct
        layout  :lifn_family, :sa_family_t,
                :lifn_flags, :int,
                :lifn_count, :int
      end

      class Arpreq < FFI::Struct
        layout  :arp_pa, Sockaddr,
                :arp_ha, Sockaddr,
                :arp_flags, :int

      end

      class Lifru1 < FFI::Union
        layout  :lifru_addrlen, :int,
                :lifru_ppa, :uint_t
      end

      class Lifru < FFI::Union
        layout  :lifru_addr, SockaddrStorage,
                :lifru_dstaddr, SockaddrStorage,
                :lifru_broadaddr, SockaddrStorage,
                :lifru_token, SockaddrStorage,
                :lifru_subnet, SockaddrStorage,
								:pad, [:char, 80]
      end

      class Lifreq < FFI::Struct
        layout  :lifr_name, [:char, 32],
                :lifr_lifru1, Lifru1,
								:lifr_movetoindex, :int,
                :lifr_lifru, Lifru,
                :pad, [:char, 80]
      end

      class Lifconf < FFI::Struct
        layout  :lifc_family, :uint,
                :lifc_flags, :int,
                :lifc_len, :int,
                :lifc_buf, :pointer
      end

      class Lifcu < FFI::Union
        layout  :lifcu_buf, :caddr_t,
                :lifcu_req, Lifreq
      end

			class InAddr < FFI::Struct
				layout :s_addr, :uint32_t
			end

			class SockaddrIn < FFI::Struct 
				layout 	:sin_family, :sa_family_t,
								:sin_port, :in_port_t,
								:sin_addr, InAddr,
								:sin_zero, [:char, 8]
			end
    end
  end
end
