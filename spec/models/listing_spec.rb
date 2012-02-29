require 'spec_helper'

describe Listing, "listing model" do 
  it 'converts analytics reports aggregated listing values', :vcr do 
    listing = Listing.find("123456")
    listing.should have_at_most(1).uuid
  end
end
