require 'ffi'
require 'pry'

module Socket
        extend FFI::Library
        ffi_lib '/usr/lib/libsocket.so'
        attach_function :socket, [:int, :int, :int], :int

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

class Lifru1 < FFI::Union
	layout :addrlen, :int
	#	:ppa, :uint
end

class Lifru < FFI::Union
	layout :addr, :int,
	#	:staddr, Sockaddr,
	#	:broad_addr, Sockaddr,
	#	:token, Sockaddr,
	#	:index, :int,
	#	:flags, :uint64_t,
		:metric, :int
	#	:mtu, :uint_t

end

class Lifreq < FFI::Struct
	layout  :name, [:char, 32],
		:pad, [:char, 344]
end

class Lifconf < FFI::Struct
	layout :family, :uint,
		:flags, :int,
		:len, :int,
	#	:buf, :caddr_t,
		:buf, :pointer
	#	:lifreq, Lifreq

end

class Lifcu < FFI::Union
	layout :lifcu_buf, :caddr_t,
		:lifreq, Lifreq
end

module Ioctl
        extend FFI::Library
        ffi_lib FFI::Library::LIBC
	attach_function :ioctl, [:int, :int, Lifnum], :int
end

#SCIOGLIconf -1072666203



s = Socket::socket(2,1,0)
l = Lifnum.new
l[:family] = 0
l[:flags] = 0
l[:count] = 0
p s
x = Ioctl::ioctl(s, -1072928382, l)


lifconf = Lifconf.new
lifconf[:family] = 0
lifconf[:flags] = 0
lifconf[:len] = l[:count] * 376

lifconf[:buf] = FFI::MemoryPointer.new(Lifreq, l[:count])

x2 = Ioctl::ioctl(s, -1072666203, lifconf)

p '------------'
p x2
#binding.pry
p lifconf[:buf]
lif = Lifreq.new(lifconf[:buf])
lif2 = Lifreq.new(lifconf[:buf] + 376)
lif3 = Lifreq.new(lifconf[:buf] + 376 + 376)
lif4 = Lifreq.new(lifconf[:buf] + 376 + 376 + 376)
binding.pry
#p lif[:name].get_bytes(0, 32 * 2)


p FFI::LastError.error
p l[:count]

