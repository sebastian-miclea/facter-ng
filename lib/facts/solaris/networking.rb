# frozen_string_literal: true

module Facts
  module Solaris
    class Networking
      FACT_NAME = 'networking'

      def call_the_resolver
        fact_value = Facter::Resolvers::Networking.resolve(:all)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
