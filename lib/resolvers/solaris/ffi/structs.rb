module Facter
  module Resolvers
    module Solaris

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

        class Lifru1 < FFI::Union
          layout :addrlen, :int
          # :ppa, :uint
        end

        class Lifru < FFI::Union
          layout :addr, :int,
          # :staddr, Sockaddr,
          # :broad_addr, Sockaddr,
          # :token, Sockaddr,
          # :index, :int,
          # :flags, :uint64_t,
            :metric, :int
          # :mtu, :uint_t

        end

        class Lifreq < FFI::Struct
          layout  :name, [:char, 32],
            :pad, [:char, 344]
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
