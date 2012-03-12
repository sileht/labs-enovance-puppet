require 'spec_helper'
describe 'resolver' do
  it { should include_class('resolver::config') }
  it { should include_class('resolver::packages') }
  it { should include_class('resolver::params') }
  it { should include_class('resolver::services') }
end
