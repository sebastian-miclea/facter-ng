module Facter
  module Resolvers
    module Solaris
        module Socket
          extend FFI::Library
          ffi_lib '/usr/lib/libsocket.so'
          attach_function :socket, [:int, :int, :int], :int
        end

        module Ioctl
          extend FFI::Library
          ffi_lib FFI::Library::LIBC
          attach_function :ioctl_lifnum, :ioctl, [:int, :int, Facter::Resolvers::Solaris::Lifnum], :int
          attach_function :ioctl_arpreq, :ioctl, [:int, :int, Facter::Resolvers::Solaris::Arpreq], :int        
	end
      end
  end
end
