# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "json"
require "open-uri"

Movie.destroy_all

api_url = "https://tmdb.lewagon.com/movie/top_rated"
serialized_response = URI.parse(api_url).read
response = JSON.parse(serialized_response)
datas = response["results"]

datas.each do |movie|
  Movie.create(title: movie["title"], api_endpoint: movie["id"], user_id: 1)
end
