class MoviesController < ApplicationController
  before_action :authenticate_user!
   def index
    @movies = current_user.movies
  end

  def show
    @movie = current_user.movies.find(params[:id])
  end

  def create
    @movie = current_user.movies.find_or_initialize_by(
      api_endpoint: movie_params[:api_endpoint]
    )
#     Cette méthode recherche le film dans la collection de Gertrude.
#  S'il existe, elle récupère le film existant.
#  Sinon, elle initialise un nouvel objet Movie, sans encore le sauvegarder.

    if @movie.new_record?
      @movie.title = movie_params[:title]
      @movie.seen = false
    end
    # new_record? : permet de vérifier si le film n'est pas encore enregistré dans la DB.
    # Cela évite notamment de remettre seen à false pour un film que Gertrude aurait déjà regardé.

    if @movie.save
      redirect_back fallback_location: movies_path,
                    status: :see_other,
                    notice: "Film ajouté à mes films."
    else
      redirect_back fallback_location: movies_path,
                    alert: "Impossible d'ajouter ce film."
    end
  end

  def update
    @movie = current_user.movies.find(params[:id])
    @movie.update!(seen_params)
    redirect_to movies_path, status: :see_other
  end

  private

  def movie_params
    params.require(:movie).permit(:title, :api_endpoint)
  end

  def seen_params
    params.require(:movie).permit(:seen)
  end
end
