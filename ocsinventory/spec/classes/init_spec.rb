require 'spec_helper'
describe 'ocsinventory' do
  let(:params) { 
    { 
      :url              => "https://ocsinventory.example.com/ocsinventory",
    }
  }

  # test included subclasses
  it { should include_class('ocsinventory::config') }
  it { should include_class('ocsinventory::packages') }
  it { should include_class('ocsinventory::params') }

  # test package installation
  it { should contain_package('ocsinventory-agent').with( 
            'ensure' => 'present' )
  }

  # check ocsinventory update execution
  it { should contain_exec('ocs-update').with(
            'command'       => '/usr/bin/ocsinventory-agent',
            'refreshonly'   => 'true' )
  }

  # test /etc/ocsinventory/ocsinventory-agent.cfg
  it { should contain_file('/etc/ocsinventory/ocsinventory-agent.cfg').with(
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0640' )
  }
  it "should have a valid default" do
    content = param_value(subject, 'file', '/etc/ocsinventory/ocsinventory-agent.cfg', 'content')
    expected_lines = [
      'server=https://ocsinventory.example.com/ocsinventory',
    ]
    (content.split("\n") & expected_lines).should == expected_lines
  end

end
