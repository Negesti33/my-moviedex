class AddUserReferenceToMovies < ActiveRecord::Migration[8.1]
  def change
    add_reference :movies, :user, foreign_key: true
  end
end
