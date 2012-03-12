require 'spec_helper'
describe 'puppet-agent' do
  it { should include_class('puppet-agent::config') }
  it { should include_class('puppet-agent::packages') }
  it { should include_class('puppet-agent::params') }
  it { should include_class('puppet-agent::services') }
end
