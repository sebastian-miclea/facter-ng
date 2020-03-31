# frozen_string_literal: true

describe Facts::Debian::Os::Distro::Codename do
  describe '#call_the_resolver' do
    subject(:fact) { Facts::Debian::Os::Distro::Codename.new }

    let(:value) { 'stretch' }

    before do
      allow(Facter::Resolvers::OsRelease).to receive(:resolve).with(:version_codename).and_return(value)
    end

    it 'calls Facter::Resolvers::OsRelease' do
      fact.call_the_resolver
      expect(Facter::Resolvers::OsRelease).to have_received(:resolve).with(:version_codename)
    end

    it 'returns os.distro.codename fact' do
      expect(fact.call_the_resolver).to be_an_instance_of(Facter::ResolvedFact).and \
        have_attributes(name: 'os.distro.codename', value: value)
    end
  end
end
