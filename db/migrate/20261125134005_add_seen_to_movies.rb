class AddSeenToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :seen, :boolean, default: false, null: false
  end
end
