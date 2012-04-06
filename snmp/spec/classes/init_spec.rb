require 'spec_helper'
describe 'snmp' do
  let(:params) { 
    {
      :start            => 'yes',
      :daemonoptions    => '-c /etc/snmp/snmpd_acl.conf',
      :sec_model        => [ "v2c", "usm",],
      :users            => { 'Ro'    => { 
                            'write'     => 'none',
                            'group'     => 'RO-Group' },
                             'Rw'    => {
                            'write'     => 'all',
                            'group'     => 'RW-Group' }
                           },
      :sources          => { 'localhost' => '127.0.0.1', 'source1' => '1.2.3.4',}
    }
  }

  let(:node) { 'foo.example.com' }

  # test included subclasses
  it { should include_class('snmp::config') }
  it { should include_class('snmp::packages') }
  it { should include_class('snmp::params') }
  it { should include_class('snmp::services') }

  # test Debian/Ubuntu specific values
  describe 'Debian' do
    let(:facts){{
        :operatingsystem    => 'Debian',
        :whereami           => 'physcal_server_1',
        :datacenter         => 'datacenter1',
        :hostname           => 'foo.example.com',
      }}

    # test package installation
    it { should contain_package('snmp').with( 
              'ensure' => 'present' )
    }

    # test services
    it { should contain_service('snmpd').with(
              'ensure' => 'true' )
    }

    # ensure /etc/snmp is created
    it { should contain_file('/etc/snmp').with_ensure('directory') }

    # test /etc/snmp/main.cf
    it { should contain_file('/etc/snmp/snmp.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }

    # test /etc/snmp/snmpd_checks.conf
    it { should contain_file('/etc/snmp/snmpd_checks.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }

    # test /etc/snmp/snmpd_acl.conf
    it { should contain_file('/etc/snmp/snmpd_acl.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/snmp/snmpd_acl.conf', 'content')
      expected_lines = [
        '# localhost',
        'com2sec Rw  127.0.0.1       Rw',
        'com2sec Ro  127.0.0.1       Ro',
        '# source1',
        'com2sec Rw  1.2.3.4       Rw',
        'com2sec Ro  1.2.3.4       Ro',
        'group RW-Group v2c      Rw',
        'group RO-Group v2c      Ro',
        'group RW-Group usm      Rw',
        'group RO-Group usm      Ro',
        'access RW-Group ""  any     noauth  exact   all all    none',
        'access RO-Group ""  any     noauth  exact   all none    none',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end

    # test /etc/snmp/snmpd.conf
    it { should contain_file('/etc/snmp/snmpd.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }

    # test /etc/snmp/contact.conf
    it { should contain_file('/etc/snmp/snmpd_contact.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/snmp/snmpd_contact.conf', 'content')
      expected_lines = [
        'syslocation "foo.example.com @ physcal_server_1 @ datacenter1"',
        'syscontact eNovance <admin@enovance.com>',
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end


    # test /etc/snmp/snmptrapd.conf
    it { should contain_file('/etc/snmp/snmptrapd.conf').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }

    # test /etc/default/snmpd
    it { should contain_file('/etc/default/snmpd').with(
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0760' )
    }
    it "should have a valid default" do
      content = param_value(subject, 'file', '/etc/default/snmpd', 'content')
      expected_lines = [
        'SNMPDRUN=yes',
        "SNMPDOPTS='-c /etc/snmp/snmpd_acl.conf'",
      ]
      (content.split("\n") & expected_lines).should == expected_lines
    end
  end

  describe 'Other OS' do
    let(:facts){{
        :operatingsystem => 'Other',
      }}
    it { should_not contain_package('snmp') }
    it { should_not contain_service('snmpd') }
    it { should_not contain_file('/etc/snmp') }
    it { should_not contain_file('/etc/snmp/snmpd_checks.conf') }
    it { should_not contain_file('/etc/snmp/snmpd_acl.conf') }
    it { should_not contain_file('/etc/snmp/snmpd.conf') }
    it { should_not contain_file('/etc/snmp/snmpd_contact.conf') }
    it { should_not contain_file('/etc/snmp/snmptrapd.conf') }
    it { should_not contain_file('/etc/default/snmpd') }
  end

end
