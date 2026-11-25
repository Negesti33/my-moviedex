class Movie < ApplicationRecord
  validates :title, :api_endpoint, presence: true
end
