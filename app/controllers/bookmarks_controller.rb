class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @error = bookmark.save ? "ok" : "retry"
    redirect_to movie_path(@movie)
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:movie_id)
  end
end
