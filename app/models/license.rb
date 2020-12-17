class License < ApplicationRecord
  belongs_to :game

  validates :key, :game, presence: true
end
