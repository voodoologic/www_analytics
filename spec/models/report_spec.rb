require 'spec_helper'
  describe Report do 
    before(:each) do 
      @report ||= Report.new({report: 'agent listing',  agent: '2acf67e5-75d1-482b-87ae-c4e4ad75a994', start_date: "2012-01-27", office: 8008563})
    end
    it 'should be an an object'  do 
      @report.should be_kind_of(Report)
    end
    it 'should have results'  do 
      @report.should respond_to(:results)
    end
    it 'should have results'  do 
      @report.should respond_to(:office)
    end
    it 'should have results'  do 
      @report.should respond_to(:agent)
    end
    it 'should have results' do 
      @report.should respond_to(:columns)
    end
    it "report results will be an empty set" do
      mock_report = mock 'Report'
      mock_report.should_receive(:results).and_return([])
      mock_report.results.should == []
    end

    it "should aggregate the different page paths" do
      @listing_page_visits.should be_kind_of(Array)
    end

    context "report has analytics results" 

        # mock_report Report.new({report: 'agent listing',  agent: '2acf67e5-75d1-482b-87ae-c4e4ad75a994', start_date: "2012-01-27", office: 8008563})
      it 'should have at least one result'   do 
        @report.should have_at_least(1).results
      end
  end
