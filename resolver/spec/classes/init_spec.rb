require 'spec_helper'
describe 'resolver' do
  let(:params) { 
    {
      :dcinfo      => { 'dc1'   => ['1.2.3.4', '5.6.7.8', '9.0.1.2'],
                        'dc2'   => ['3.4.5.6', '7.8.9.1', '2.3.4.5']
                },
      :domainname  => 'enovance.com',
      :searchpath  => 'enovance.com',
      :publicdns   => ['8.8.8.8']
    }
  }

  # test included subclasses
  it { should include_class('resolver::config') }
  it { should include_class('resolver::params') }

  # test Debian/Ubuntu specific values
  let(:facts){{
    :datacenter         => 'dc2',
  }}

  # test /etc/resolv.conf
  it { should contain_file('/etc/resolv.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0644' )
  }
  it "should have a valid default" do
    content = param_value(subject, 'file', '/etc/resolv.conf', 'content')
    expected_lines = [
      'search enovance.com',
      'nameserver 3.4.5.6',
      'nameserver 7.8.9.1',
      'nameserver 2.3.4.5',
      'nameserver 8.8.8.8',
      'options timeout:1',
      'options attempts:1'
    ]
    (content.split("\n") & expected_lines).should == expected_lines
    end
end
