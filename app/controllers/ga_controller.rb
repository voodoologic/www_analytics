class GaController < ApplicationController # before_filter :profiles_list

  def report   
    @title = "Windermere analytics test report"
    unless params[:report].nil?
      if !params[:report][:listing].blank?
        redirect_to listing_path(:listingid => Report.snipe_listing_from_url(params[:report][:listing]))
        return 
      else
        @report = Report.new(params[:report])
        @results = @report.results
        @agent   = @report.agent
        @listings = @report.listings
        @columns = @report.columns
        if @results.count == 0
          redirect_to request.referer
          gflash :warning => "Found zero results for #{@agent.display_name}."
        else
          aggregate_listings
          #gflash  :success => {:value =>  "OOOHHH YEAH!!!! Listing report for #{@agent.display_name}", :image => @agent.image.first["thumb_url"]}
        end
      end
    end
  end

  def listing
    @title   = "Windermere analytics test report"
    # @results = Report.new(params[:report])
    @report = Report.new({listingid: params[:listingid]})
    @results = @report.results
    if @results.empty? 
      redirect_to request.referer
      gflash :warning => "Found zero results for listing given."
    else
      @listing = @report.listings.first
      @listings = @report.listings
      @agent   = @report.agent
      @columns = @report.columns
      @visitor_map = @report.results.map{|x| [x.latitude, x.longitude]}.sample(map_sample(@results.count))
      aggregate_listings
      gflash  :success => {:value =>  "Listing report for #{@listing.location.address}", :image => @listing.images.first["thumb_url"]}
    end
  end

  private

  # keeps the google map from erroring out 
  def map_sample(results_count)
    if results_count < 90
      results_count
    else 
      90
    end
  end

  def aggregate_listings
    @listing_page_visits = Array.new
    @listings.each { |listing|
      @date_visits = Hash.new(0)
      @results.each{ |result|
        if result.send(@columns[0]).include? listing.listingid.to_s
          visits = @date_visits[result.send(@columns[1])]
          if visits == 0
            visits = Array.new(3, 0)
          end

          if result.send(@columns[0]).include? "refer=map"
            visits[0] += result.send(@columns[2]).to_i # pageviews
          elsif result.send(@columns[0]).include? "/gallery"
            visits[1] += result.send(@columns[2]).to_i
          else
            visits[2] += result.send(@columns[2]).to_i
          end

          @date_visits[result.send(@columns[1])] = visits

        end
      }

      #puts Hash[@date_visits.sort]
      @listing_page_visits << [listing.listingid, Hash[@date_visits.sort]]
    }
  end
end

