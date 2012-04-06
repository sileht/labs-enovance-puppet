require 'spec_helper'
describe 'ntp' do
  let(:params) { 
    {
      :ntpservers      => [ '0.debian.pool.ntp.org',
                        '1.debian.pool.ntp.org',
                        '2.debian.pool.ntp.org',
                        '3.debian.pool.ntp.org' ]
    }
  }

  # test included subclasses
  it { should include_class('ntp::config') }
  it { should include_class('ntp::packages') }
  it { should include_class('ntp::params') }
  it { should include_class('ntp::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem    => 'Debian',
      }}

    # test package installation
    it { should contain_package('ntp').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('ntp').with(
              'ensure' => 'true' )
    }

    # test /etc/ntp.conf
    it { should contain_file('/etc/ntp.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0640' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/ntp.conf', 'content')
      expected_lines = [
        'server 0.debian.pool.ntp.org iburst',
        'server 1.debian.pool.ntp.org iburst',
        'server 2.debian.pool.ntp.org iburst',
        'server 3.debian.pool.ntp.org iburst'
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('ntp') }
    it { should_not contain_service('ntp') }
    it { should_not contain_file('/etc/ntp.conf') }
  end

end
