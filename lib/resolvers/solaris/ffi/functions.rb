module Facter
  module Resolvers
    module Solaris
      module FFI
        module Socket
          extend FFI::Library
          ffi_lib '/usr/lib/libsocket.so'
          attach_function :socket, [:int, :int, :int], :int
        end

        module Ioctl
          extend FFI::Library
          ffi_lib FFI::Library::LIBC
          attach_function :ioctl, [:int, :int, Facter::Resolvers::Solaris::FFi::Lifnum], :int
        end
      end
    end
  end
end
