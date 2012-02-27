class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :current_office
  def current_office
    if params[:office_slug]
      @office = Office.find_by_slug(params[:office_slug])
    elsif params[:listingid]
      uuid = Listing.find(params[:listingid]).office.uuid
      @office = Office.find(uuid) unless uuid.nil?
    else
      @office =  Office.find(8008563)
    end
  end
end
