require 'spec_helper'
describe 'muninnode' do
  let(:params) { 
    {
      :sources     => { 'localhost'    => '^127\.0\.0\.1$',
                   'host1'             => '^1\.2\.3\.4$',
                   'host2'             => '^5\.6\.7\.8$'},
      :port        => 4949, 
    }
  }

  # test included subclasses
  it { should include_class('muninnode::config') }
  it { should include_class('muninnode::packages') }
  it { should include_class('muninnode::params') }
  it { should include_class('muninnode::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem    => 'Debian',
      }}

    # test package installation
    it { should contain_package('munin-node').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('munin-node').with(
              'ensure' => 'true' )
    }

    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/munin/munin-node.conf', 'content')
      expected_lines = [
        '# host1',
        'allow   ^1\.2\.3\.4$',
        '# host2',
        'allow   ^5\.6\.7\.8$',
        '# localhost',
        'allow   ^127\.0\.0\.1$',
        'port 4949',
      ]
      #(content.split("\n") ).should == expected_lines
      (content.split("\n") & expected_lines).should == expected_lines
    end
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('munin-node') }
    it { should_not contain_service('munin-node') }
    it { should_not contain_file('/etc/munin/munin-node.conf') }
  end

end
