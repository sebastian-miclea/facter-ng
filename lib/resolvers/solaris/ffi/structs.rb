module Facter
  module Resolvers
    module Solaris

      class SockaddrStorage < FFI::Struct
        layout  :ss_family, :uint16,
                :pad, [:char, 240]
      end

      class Sockaddr < FFI::Struct
        layout  :sa_family, :sa_family_t,
                :sa_data, [:char, 14]

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
                :lifru_subnet, SockaddrStorage
      end

      class Lifreq < FFI::Struct
        layout  :name, [:char, 32],
                :lifru1, Lifru1,
                :lifru, Lifru,
                :pad, [:char, 96]
      end

      class Lifconf < FFI::Struct
        layout  :family, :uint,
                :flags, :int,
                :len, :int,
                :buf, :pointer
      end

      class Lifcu < FFI::Union
        layout  :lifcu_buf, :caddr_t,
                :lifreq, Lifreq
      end
    end
  end
end
