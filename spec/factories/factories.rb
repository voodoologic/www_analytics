require 'date'
FactoryGirl.define do 
  factory :report_params do 
    report 'agent list'
    agent '2acf67e5-75d1-482b-87ae-c4e4ad75a994'
    start_date 1.month.ago
    end_date Date.today
    office 8008563
  end
end
