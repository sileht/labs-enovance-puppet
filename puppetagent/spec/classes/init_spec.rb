require 'spec_helper'
describe 'puppetagent' do
  let(:params) { 
    { 
      :server           => "puppet.example.com",
      :start            => false,
      :pluginsync       => true,
      :daemonoptions    => '--onetime',
    }
  }
  let(:environment) { 'development' }

  # test included subclasses
  it { should include_class('puppetagent::config') }
  it { should include_class('puppetagent::packages') }
  it { should include_class('puppetagent::params') }
  it { should include_class('puppetagent::services') }

  # test package installation
  it { should contain_package('puppet').with( 
            'ensure' => 'present' )
  }

  # test services
  it { should contain_service('puppet').with(
            'ensure' => 'true' )
  }

  # test /etc/puppet/puppet.conf
  it { should contain_file('/etc/puppet/puppet.conf').with(
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0640' )
  }
  it "should have a valid default" do
    content = param_value(subject, 'file', '/etc/puppet/puppet.conf', 'content')
    expected_lines = [
      '[main]',
      '  logdir            = /var/log/puppet',
      '  vardir            = /var/lib/puppet',
      '  ssldir            = /var/lib/puppet/ssl',
      '  rundir            = /var/run/puppet',
      '  factpath          = $vardir/lib/facter',
      '  templatedir       = $confdir/templates',
      '',
      '  # puppet master address',
      '  server            = puppet.example.com',
      '',
      '  # synchronize fact',
      '  pluginsync        = true',
      '',
      '  # set environment',
      '  environment       = production',
      '',
      '  # enable reporting',
      '  report            = true',
    ]
    (content.split("\n")).should == expected_lines
  end

  # test /etc/default/puppet
  it { should contain_file('/etc/default/puppet').with(
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0640' )
  }
  it "should have a valid default" do
    content = param_value(subject, 'file', '/etc/default/puppet', 'content')
    expected_lines = [
      '# Defaults for puppet - sourced by /etc/init.d/puppet',
      '',
      '# Start puppet on boot?',
      'START=false',
      '',
      '# Startup options',
      'DAEMON_OPTS="--certname=`cat /etc/hostname` --onetime"',
    ]
    (content.split("\n")).should == expected_lines
  end

end
