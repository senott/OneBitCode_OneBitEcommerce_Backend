FactoryBot.define do
  factory :license do
    key { Faker::Code.npi }
    game { game }
  end
end
