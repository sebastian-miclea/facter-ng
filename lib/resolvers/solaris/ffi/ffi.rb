# frozen_string_literal: true

require 'ffi'
require_relative 'structs.rb'
require_relative 'functions.rb'

module Facter
  module Resolvers
    module Solaris
      SIOCGLIFNUM     = -1072928382
      SIOCGLIFCONF    = -1072666203
      SIOCGLIFMTU     = -1065850502
      SIOCGLIFNETMASK = -1065850499
      SIOCGARP        = -1071355617
      AF_INET         = 2
			AF_INET6				= 26
      AF_UNSPEC       = 0
      SOCK_DGRAM      = 1
			INET_ADDRSTRLEN = 16
			INET6_ADDRSTRLEN= 46
    end
  end
end


# 2020-06-29 03:57:11.378422 DEBUG puppetlabs.facter - FFI: buffer size: 2
# 2020-06-29 03:57:11.378488 DEBUG puppetlabs.facter - FFI: lifreq size: 376
# 2020-06-29 03:57:11.378559 DEBUG puppetlabs.facter - FFI: SIOCGLIFCONF: -1072666203
# 2020-06-29 03:57:11.378617 DEBUG puppetlabs.facter - FFI: SIOCGLIFMTU: -1065850502
# 2020-06-29 03:57:11.378683 DEBUG puppetlabs.facter - FFI: SIOCGLIFNETMASK: -1065850499
# 2020-06-29 03:57:11.378742 DEBUG puppetlabs.facter - FFI: sizeof_sockaddr: 16
# 2020-06-29 03:57:11.378802 DEBUG puppetlabs.facter - FFI: sizeof sockaddr_storage: 256
# 2020-06-29 03:57:11.378877 DEBUG puppetlabs.facter - FFI: sizeof_arpreq: 36
# 2020-06-29 03:57:11.378933 DEBUG puppetlabs.facter - FFI: sizeof in_addr: 4
# 2020-06-29 03:57:11.378999 DEBUG puppetlabs.facter - FFI: sizeof sockaddr_in: 16

