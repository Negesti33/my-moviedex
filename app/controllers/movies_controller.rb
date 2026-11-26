class MoviesController < ApplicationController
  before_action :authenticate_user!
  def index
    @movies = Movie.all.where(user_id: current_user.id)
  end

  def show
    @movie = Movie.find(params[:id])
  end
end
