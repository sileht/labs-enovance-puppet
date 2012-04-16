require 'spec_helper'
describe 'ssh' do
  let(:params) { 
    {
      #no params
    }
  }

  # test included subclasses
  it { should include_class('ssh::config') }
  it { should include_class('ssh::packages') }
  it { should include_class('ssh::params') }
  it { should include_class('ssh::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem    => 'Debian',
      }}

    # test package installation
    it { should contain_package('openssh-server').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('ssh').with(
              'ensure' => 'true' )
    }
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('openssh-server') }
    it { should_not contain_service('ssh') }
  end

end
