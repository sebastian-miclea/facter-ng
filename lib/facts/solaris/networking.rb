# frozen_string_literal: true

module Facts
  module Solaris
    class Networking2
      FACT_NAME = 'networking2'

      def call_the_resolver
        fact_value = Facter::Resolvers::Solaris::Networking2.resolve(:all)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end
