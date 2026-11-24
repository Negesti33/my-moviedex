class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :api_endpoint

      t.timestamps
    end
  end
end
