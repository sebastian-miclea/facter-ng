# frozen_string_literal: true

describe Facts::Macosx::Networking::Hostname do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Macosx::Networking::Hostname.new }

    let(:value) { 'host' }

    before do
      allow(Facter::Resolvers::Hostname).to receive(:resolve).with(:hostname).and_return(value)
    end

    it 'calls Facter::Resolvers::Hostname' do
      fact.call_the_resolver
      expect(Facter::Resolvers::Hostname).to have_received(:resolve).with(:hostname)
    end

    it 'returns hostname fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Array).and \
        contain_exactly(an_object_having_attributes(name: 'networking.hostname', value: value),
                        an_object_having_attributes(name: 'hostname', value: value, type: :legacy))
    end
  end
end
