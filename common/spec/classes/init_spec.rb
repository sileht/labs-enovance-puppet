require 'spec_helper'
describe 'common' do
  it { should include_class('common::config') }
  it { should include_class('common::packages') }
  it { should include_class('common::params') }
  it { should include_class('common::services') }
end
