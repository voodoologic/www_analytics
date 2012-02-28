require 'spec_helper'
  describe Report do 
    before(:each) do 
      @report = Report.new({report: 'agent listing',  agent: '2acf67e5-75d1-482b-87ae-c4e4ad75a994', start_date: "2012-01-27", office: 8008563})
    end
    it 'should be an an object', :vcr => true  do 
      @report.should be_kind_of(Report)
    end
    it 'should have results', :vcr => true  do 
      @report.should respond_to(:results)
    end
    it 'should have results', :vcr => true  do 
      @report.should respond_to(:office)
    end
    it 'should have results', :vcr => true  do 
      @report.should respond_to(:agent)
    end
    it 'should have results', :vcr => true  do 
      @report.should respond_to(:columns)
    end
    context "report has analytics results" do 
      it 'should have at least one result', :vcr => true  do 
        @report.should have_at_least(1).results
      end
    end
    describe "report has no analytical results" do 
      report = Report.new({report: 'agent listing',  agent: '2acf67e5-75d1-482b-87ae-c4e4ad75a994', start_date: "2012-01-27", office: 8008563})
      report.stub!(:filtered_results).and_return(0)
      report.results.should_not be(nil) && report.resuts.should == 0
    end

    describe @report.results do 
      before(:each) do 
        @report = Report.new({report: 'agent listing',  agent: '2acf67e5-75d1-482b-87ae-c4e4ad75a994', start_date: "2012-01-27", office: 8008563})
      end
    end
end
