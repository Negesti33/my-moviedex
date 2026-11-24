class Movie < ApplicationRecord
  has_many :bookmarks

  validates :title, :api_endpoint, presence: true
end
