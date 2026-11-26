class PositionsController < ApplicationController
  def create
    latitude = params[:latitude]
    longitude = params[:longitude]

    return head :bad_request if latitude.blank? || longitude.blank?

    session[:latitude] = latitude.to_f
    session[:longitude] = longitude.to_f

    head :no_content
  end
end
