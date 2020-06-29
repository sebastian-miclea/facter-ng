# frozen_string_literal: true

require 'ffi'
require_relative 'structs.rb'
require_relative 'functions.rb'

module Facter
  module Resolvers
    module Solaris
      module FFI
        SIOCGLIFNUM = -1072928382
        SIOCGLIFCONF = -1072666203
        AF_INET = 2
        AF_UNSPEC = 0
        SOCK_DGRAM = 1
      end
    end
  end
end

