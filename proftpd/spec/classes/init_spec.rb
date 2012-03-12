require 'spec_helper'
describe 'proftpd' do
  it { should include_class('proftpd::config') }
  it { should include_class('proftpd::packages') }
  it { should include_class('proftpd::params') }
  it { should include_class('proftpd::services') }
end
