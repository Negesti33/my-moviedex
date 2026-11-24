class MoviesController < ApplicationController
  before_action :authenticate_user!
  def index
    @movies = Movie.all
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.new(movie_params)
    if movie.save
      redirect_to movie_path(@movie)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :api_endpoint)
  end
end
