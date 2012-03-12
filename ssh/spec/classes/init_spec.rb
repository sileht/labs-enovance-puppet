require 'spec_helper'
describe 'ssh' do
  it { should include_class('ssh::config') }
  it { should include_class('ssh::packages') }
  it { should include_class('ssh::params') }
  it { should include_class('ssh::services') }
end
