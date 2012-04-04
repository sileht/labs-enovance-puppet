require 'spec_helper'
describe 'postfix' do
  let(:params) { 
    { 
      :client           => 'foo',
      :sasl             => 'barword',
    }
  }

  let(:node) { 'myfqdn.example.com' }

  # test included subclasses
  it { should include_class('postfix::config') }
  it { should include_class('postfix::packages') }
  it { should include_class('postfix::params') }
  it { should include_class('postfix::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem => 'Debian',
      }}

    # test package installation
    it { should contain_package('postfix').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('postfix').with(
              'ensure' => 'true' )
    }

    # ensure /etc/postfix is created
    it { should contain_file('/etc/postfix').with_ensure('directory') }

    # test /etc/postfix/main.cf
    it { should contain_file('/etc/postfix/main.cf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/postfix/main.cf', 'content')
      expected_lines = [
        'myhostname = myfqdn.example.com',
        'smtp_sasl_auth_enable = yes',
        'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd',
        'smtp_sasl_type = cyrus',
        'smtp_sasl_mechanism_filter = plain, login, digest-md5, cram-md5',
        'smtp_sasl_security_options = noanonymous',
        'relayhost = [mxi2.enovance.com]',
        'fallback_relay = [mxi3.enovance.com] , [mxi1.enovance.com]',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end

    # test /etc/postfix/master.cf
    it { should contain_file('/etc/postfix/master.cf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }

    # test /etc/postfix/sasl_passwd
    it { should contain_file('/etc/postfix/sasl_passwd').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/postfix/sasl_passwd', 'content')
      expected_lines = [
        '[mxi1.enovance.com] foo:barword',
        '[mxi2.enovance.com] foo:barword',
        '[mxi3.enovance.com] foo:barword',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end

    # check that postmap is ran on /etc/postfix/sasl_passwd
    it { should contain_exec('postmap-sasl').with(
        'command'       => '/usr/sbin/postmap /etc/postfix/sasl_passwd',
        'refreshonly'   => 'true')
    }

    # ensure /etc/mailname is present, and a link to /etc/hostname
    it { should contain_file('/etc/mailname').with(
        'ensure'        => 'link',
        'target'        => '/etc/hostname')
    }
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('postfix') }
    it { should_not contain_service('postfix') }
    it { should_not contain_file('/etc/postfix') }
    it { should_not contain_file('/etc/postfix/main.cf') }
    it { should_not contain_file('/etc/postfix/master.cf') } 
    it { should_not contain_file('/etc/postfix/sasl_passwd') } 
    it { should_not contain_exec('postmap-sasl') }
    it { should_not contain_file('/etc/mailname') }
  end

end
