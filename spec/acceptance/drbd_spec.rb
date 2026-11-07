# frozen_string_literal: true

require 'spec_helper_acceptance'

# The drbd kernel module can't be loaded in a container, so don't load it
# and don't start the service.
describe 'drbd' do
  it_behaves_like 'an idempotent resource' do
    let(:manifest) do
      <<-PUPPET
      class { 'drbd':
        load_kernel_module => false,
        service_ensure     => 'stopped',
        service_enable     => false,
      }

      drbd::resource { 'r0':
        host1  => 'node1',
        host2  => 'node2',
        ip1    => '192.0.2.1',
        ip2    => '192.0.2.2',
        disk   => '/dev/sdb1',
        manage => false,
      }
      PUPPET
    end
  end

  describe package('drbd-utils') do
    it { is_expected.to be_installed }
  end

  describe file('/etc/drbd.conf') do
    its(:content) { is_expected.to match %r{^include "/etc/drbd.d/\*\.res";$} }
  end

  describe file('/etc/drbd.d/global_common.conf') do
    its(:content) { is_expected.to match %r{^  usage-count no;$} }
    its(:content) { is_expected.to match %r{^  protocol C;$} }
  end

  describe file('/etc/drbd.d/r0.res') do
    it { is_expected.to be_file }
    it { is_expected.to be_mode 600 }
    its(:content) { is_expected.to match %r{^resource r0 \{$} }
    its(:content) { is_expected.to match %r{^  disk      /dev/sdb1;$} }
    its(:content) { is_expected.to match %r{^  on node1 \{\n    address 192\.0\.2\.1:7789;$} }
    its(:content) { is_expected.to match %r{^  on node2 \{\n    address 192\.0\.2\.2:7789;$} }
  end

  describe file('/drbd/r0') do
    it { is_expected.to be_directory }
  end

  describe service('drbd') do
    it { is_expected.not_to be_enabled }
    it { is_expected.not_to be_running }
  end
end
