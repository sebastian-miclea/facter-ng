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
