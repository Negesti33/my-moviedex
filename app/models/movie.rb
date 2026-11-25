class Movie < ApplicationRecord
  belongs_to :user

  validates :title, :api_endpoint, presence: true
end
