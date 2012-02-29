class Report < Garb::ResultSet
  require 'rubygems'
  require 'wms_svc_consumer'
  require 'date'
  attr_accessor :uuid, :date_dimension, :agent, :office, :columns, :listings, :results, :report, :start_date
  USER = Rails.application.config.analytics_login[:user]
  PASSWORD = Rails.application.config.analytics_login[:password]
  Garb::Session.login(USER, PASSWORD)
  def initialize(params)
    query(params)
    super(@results)
  end

  def query(params)
    profile =  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    # if !params["report"].blank?
    if !params[:listingid].blank?
      # only one listing, but creating an array for use in methods below
      @listings = Array.new(1, Listing.find(params[:listingid]) )
      @agent = @listings.first.agent
      @listingsIds = @listings.map(&:listingid)
      @results = filtered_results(GoogleAnalytics.const_get(param_to_class('social media')).results(profile,
                                                                        :filters => {:page_path.contains => @listingsIds.first},
                                                                        :end_date => Date.today,
                                                                        :start_date => 1.month.ago
                                                                        )
                                  )

    elsif params[:agent]
      @agent = Agent.find(params[:agent])
      @listings = Listing.find_all_by_agent(@agent.uuid).results
      @listingsIds = @listings.map(&:listingid)
      @results = filtered_results(GoogleAnalytics.const_get(param_to_class(params[:report])).results(profile,
                                                                         :filters => listings_to_filters(@listingsIds),
                                                                         :end_date => Date.today,
                                                                         :start_date => Date.parse(params[:start_date])
                                                                        )
                                  )

    end
    @columns = column_generator
  end

  def test
    profile ||=  Garb::Management::Profile.all.detect{|p| p.web_property_id == "UA-384279-1"}
    GoogleAnalytics.const_get("Agent Listing").results(profile, 
                                      :filters => listings_to_filters(11736186),
                                      :end_date => ::Date.today,
                                      :start_date => 1.month.ago.to_date
                                      )
  end
  
  def listings_to_filters(listing_ids)
    filters = []
    if listing_ids.kind_of?(Array)
      for listing_id in listing_ids
        filters << {:page_path.contains => listing_id}
      end
    else
      filters = {:page_path.contains => listing_ids}
    end
    return filters
  end

  def filtered_results(results)
    unless results.nil?
      filtered_results = []
      results.each do |result|
        filtered_results << result if result.send(:page_path).match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
      end
      assign_uuid_to_result(filtered_results)
    else
      []
    end
  end

  #assigns uuid to results
  def assign_uuid_to_result(filtered_results)
    filtered_results.class.instance_eval('attr_accessor :uuid, :date_dimension, :latitude, :longitude')
    @listingsIds.each do |id|
      filtered_results.each do |listing|
        if listing.send(:page_path).match(/#{id}/)
          listing.uuid = id
        end
      end
    end
    return filtered_results
  end

  #grab the listing id from url string
  def self.snipe_listing_from_url(listing_url)
    snipe = listing_url.match(/\/listing(\/[\w\-]+){4}|\/listings\/(\d{7,})\/gallery(\?refer=map)?/)
    if snipe
      result1, result2, result3 = snipe[1], snipe[2], snipe[3]
      if result1
        listingid = result1.sub("/","")
      elsif result2
        listingid = result2
      elsif result3
        listing = result3
      end
    end
  end

  def param_to_class(report)
    report.split.collect {|x| x.capitalize}.join
  end

  def arrange_columns(fields)
    #these values need to be in every Garb::Model report.
    sorting_arrangement_key = [:page_path, :date, :pageviews, :unique_pageviews]
    # remove the neccessary dimensions and metrics then push them back into the front of array
    extra_fields = fields - sorting_arrangement_key
    sorting_arrangement_key.each_with_index do |sym, index|
      extra_fields.insert(index, sym)
    end
    return extra_fields
  end
  
  #does the same thing as aggregate_listings in controller but as a hash object
  def set_dates(results)
    date_dimension = []
    for result in results
      stored_element = date_dimension.detect { |element| element[:date].to_s == result.send(:date).to_s }
      if stored_element
        stored_element[:value][:pageviews] += result.send(:pageviews).to_i
        stored_element[:value][:unique_pageviews] += result.send(:unique_pageviews).to_i
      else
        date_dimension << {:date => result.send(:date).to_s, :value => {:pageviews => result.send(:pageviews).to_i, :unique_pageviews => result.send(:unique_pageviews).to_i} }
      end
      result.date_dimension = date_dimension
    end
  end



  def column_generator
    unless @results.nil?
      @columns = arrange_columns( @results.first.fields )
    else
      @columns = [:page_path, :date, :pageviews, :unique_pageviews]
    end
  end

  # attempt to refactor this into model
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

