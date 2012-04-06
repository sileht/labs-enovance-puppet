require 'spec_helper'
describe 'monit' do
  let(:params) { 
    {
      :start            => '1',
      :email            => 'foo@example.org'
    }
  }

  # test included subclasses
  it { should include_class('monit::config') }
  it { should include_class('monit::packages') }
  it { should include_class('monit::params') }
  it { should include_class('monit::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem    => 'Debian',
      }}

    # test package installation
    it { should contain_package('monit').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('monit').with(
              'ensure' => 'true' )
    }

    # ensure /etc/monit is created
    it { should contain_file('/etc/monit').with_ensure('directory') }

    # ensure /etc/monit/conf.d is created
    it { should contain_file('/etc/monit/conf.d').with_ensure('directory') }

    # test /etc/monit/monitrc
    it { should contain_file('/etc/monit/monitrc').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0700' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/monit/monitrc', 'content')
      expected_lines = [
        'set alert foo@example.org',
        'include /etc/monit/conf.d/*',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end

    # test /etc/default/monit
    it { should contain_file('/etc/default/monit').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0640' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/default/monit', 'content')
      expected_lines = [
        'startup=1',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('monit') }
    it { should_not contain_service('monit') }
    it { should_not contain_file('/etc/monit') }
    it { should_not contain_file('/etc/monit/conf.d') }
    it { should_not contain_file('/etc/monit/monitrc') }
  end
end
