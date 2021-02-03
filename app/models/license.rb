class License < ApplicationRecord
  belongs_to :game

  enum status: { available: 1, in_use: 2, inactive: 3 }

  enum platform: { steam: 1, battle_net: 2, origin: 3 }

  validates :key, :game, :status, :platform, presence: true
end
