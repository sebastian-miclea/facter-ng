# frozen_string_literal: true

require 'ffi'
require_relative 'structs.rb'
require_relative 'functions.rb'

module Facter
  module Resolvers
    module Solaris
      SIOCGLIFNUM       = -1_072_928_382
      SIOCGLIFCONF      = -1_072_666_203
      SIOCGLIFMTU       = -1_065_850_502
      SIOCGLIFNETMASK   = -1_065_850_499
      SIOCGARP          = -1_071_355_617
      AF_INET           = 2
      AF_INET6          = 26
      AF_UNSPEC         = 0
      SOCK_DGRAM        = 1
      INET_ADDRSTRLEN   = 16
      INET6_ADDRSTRLEN  = 461
    end
  end
end
