class Movie < ApplicationRecord
  belongs_to :user

  validates :title, :api_endpoint, presence: true
  validates :api_endpoint, uniqueness: { scope: :user_id } # ligne ajoutée par ng
end
