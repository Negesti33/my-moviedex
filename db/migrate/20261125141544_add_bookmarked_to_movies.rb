class AddBookmarkedToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :bookmarked, :boolean, default: false, null: false
  end
end
