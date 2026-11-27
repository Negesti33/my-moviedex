class PositionsController < ApplicationController
  before_action :authenticate_user!
  def create
    latitude = params[:latitude]
    longitude = params[:longitude]

    return head :bad_request if latitude.blank? || longitude.blank?

    unless current_user.update(
      latitude: latitude.to_f,
      longitude: longitude.to_f
    )
      return head :unprocessable_entity
    end

    head :no_content
  end
end
