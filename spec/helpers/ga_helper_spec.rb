require 'spec_helper'
describe "report list", :vcr do 
  it 'reads the lib/google_analytics' do
    helper.reports_list.should be_an_instance_of(Array)
  end

  it 'converts filenames to readable type' do 
    file = [Rails.root.to_s, "lib/google_analytics", "/agent_listing.rb"].join("/")
    helper.reports_list.count.should == 3
  end
end
