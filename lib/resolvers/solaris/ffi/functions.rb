# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      module Socket
        extend FFI::Library
        ffi_lib '/usr/lib/libsocket.so'
        attach_function :socket, %i[int int int], :int
        attach_function :close, [:int], :int
        attach_function :inet_ntop, %i[int pointer pointer uint], :string
      end

      module Ioctl
        extend FFI::Library
        ffi_lib FFI::Library::LIBC
        attach_function :ioctl, %i[int int pointer], :int
      end
    end
  end
end
