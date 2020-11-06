FactoryBot.define do
  factory :system_requirement do
    sequence(:name) { |n| "Requirement #{n}" }
    operational_system { Faker::Computer.os }
    storage { "500 Gb" }
    processor { "AMD Ryzen 7" }
    memory { "2 Gb" }
    video_board { "GeForce X" }
  end
end
