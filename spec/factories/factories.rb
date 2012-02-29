require 'date'
FactoryGirl.define do 
  factory :report do 
    listings [OpenStruct.new()]
    agent OpenStruct.new
    results [OpenStruct.new(), OpenStruct.new()]
    columns = [:page_path, :date, :pageviews, :unique_pageviews]
  end
end
