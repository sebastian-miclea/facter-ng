# frozen_string_literal: true

describe Facter::Resolvers::Windows::Ssh do
  describe '#folders' do
    let(:programdata_dir) { 'C:/ProgramData' }

    before do
      allow(ENV).to receive(:[]).with('programdata').and_return(programdata_dir)
      allow(File).to receive(:directory?).with("#{programdata_dir}/ssh").and_return(true)

      allow(File).to receive(:readable?).with("#{programdata_dir}/ssh/ssh_host_ecdsa_key.pub").and_return(true)
      allow(File).to receive(:readable?).with("#{programdata_dir}/ssh/ssh_host_rsa_key.pub").and_return(true)
      allow(File).to receive(:readable?).with("#{programdata_dir}/ssh/ssh_host_ed25519_key.pub").and_return(true)
      allow(File).to receive(:readable?).with("#{programdata_dir}/ssh/ssh_host_dsa_key.pub").and_return(false)
      allow(File).to receive(:read).with("#{programdata_dir}/ssh/ssh_host_ecdsa_key.pub").and_return(ecdsa_content)
      allow(File).to receive(:read).with("#{programdata_dir}/ssh/ssh_host_rsa_key.pub").and_return(rsa_content)
      allow(File).to receive(:read).with("#{programdata_dir}/ssh/ssh_host_ed25519_key.pub").and_return(ed25519_content)

      allow(Facter::SshHelper).to receive(:create_ssh)
        .with('rsa', 'ssh-rsa', load_fixture('rsa_key').read.strip!)
        .and_return(rsa_result)
      allow(Facter::SshHelper).to receive(:create_ssh)
        .with('ecdsa', 'ecdsa-sha2-nistp256', load_fixture('ecdsa_key').read.strip!)
        .and_return(ecdsa_result)
      allow(Facter::SshHelper).to receive(:create_ssh)
        .with('ed25519', 'ssh-ed25519', load_fixture('ed25519_key').read.strip!)
        .and_return(ed25519_result)
    end

    after do
      Facter::Resolvers::SshResolver.invalidate_cache
    end

    context 'when ecdsa, ed25519 and rsa files exists' do
      let(:ecdsa_content) { load_fixture('ecdsa').read.strip! }
      let(:rsa_content) { load_fixture('rsa').read.strip! }
      let(:ed25519_content) { load_fixture('ed25519').read.strip! }

      let(:ecdsa_fingerprint) do
        Facter::FingerPrint.new('SSHFP 3 1 fd92cf867fac0042d491eb1067e4f3cabf54039a',
                                'SSHFP 3 2 a51271a67987d7bbd685fa6d7cdd2823a30373ab01420b094480523fabff2a05')
      end

      let(:rsa_fingerprint) do
        Facter::FingerPrint.new('SSHFP 1 1 90134f93fec6ab5e22bdd88fc4d7cd6e9dca4a07',
                                'SSHFP 1 2 efaa26ff8169f5ffc372ebcad17aef886f4ccaa727169acdd0379b51c6c77e99')
      end

      let(:ed25519_fingerprint) do
        Facter::FingerPrint.new('SSHFP 4 1 f5780634d4e34c6ef2411ac439b517bfdce43cf1',
                                'SSHFP 4 2 c1257b3865df22f3349f9ebe19961c8a8edf5fbbe883113e728671b42d2c9723')
      end

      let(:ecdsa_result) do
        Facter::Ssh.new(ecdsa_fingerprint, 'ecdsa-sha2-nistp256', ecdsa_content, 'ecdsa')
      end

      let(:rsa_result) do
        Facter::Ssh.new(rsa_fingerprint, 'ssh-rsa', rsa_content, 'rsa')
      end

      let(:ed25519_result) do
        Facter::Ssh.new(ed25519_fingerprint, 'ssh-ed22519', ed25519_content, 'ed25519')
      end

      it 'returns fact' do
        expect(Facter::Resolvers::Windows::Ssh.resolve(:ssh)).to eq([rsa_result, ecdsa_result, ed25519_result])
      end
    end
  end
end
