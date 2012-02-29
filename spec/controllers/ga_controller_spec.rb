require 'spec_helper'
describe GaController do
  it "should have a report action " do 
    get :report
    response.should render_template("report")
  end 

  it "should have a activate the listing action." do 
    post :report, :report => {:report => "Agent listing", :agent => "28c0eb81-c122-4a8b-8bf0-ef51b87d3433", :start_date =>  "2012-1-27", :listing => "http://www.windermere.com/listing/WA/Chelan/115-Lord-Acre-Rd-98816/400428"}
    assigns(:report).listings.count.should == 1
  end

  it "should redirect if listing with valid url is present" do 
    post :report, :report => {:report => "Agent listing", :agent => "28c0eb81-c122-4a8b-8bf0-ef51b87d3433", :start_date =>  "2012-1-27", :listing => "http://www.windermere.com/listing/WA/Chelan/115-Lord-Acre-Rd-98816/400428"}
    response.should be_redirect
  end

  it "should aggregate the different page paths" do
    post :report, :report => {:report => "Agent listing", :agent => "28c0eb81-c122-4a8b-8bf0-ef51b87d3433", :start_date =>  "2012-1-27", :listingid => ""}
    assigns(:listing_page_visits).should be_kind_of(Array)
  end
end
