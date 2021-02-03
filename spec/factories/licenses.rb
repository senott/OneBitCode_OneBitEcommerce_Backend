FactoryBot.define do
  factory :license do
    key { Faker::Code.npi }
    game
    status { :available }
    platform { %i[steam battle_net origin].sample }
  end
end
