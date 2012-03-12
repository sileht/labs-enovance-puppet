require 'spec_helper'
describe 'snmp' do
  it { should include_class('snmp::config') }
  it { should include_class('snmp::packages') }
  it { should include_class('snmp::params') }
  it { should include_class('snmp::services') }
end
