if Rails.env.development? || Rails.env.test?
  require 'factory_bot'

  namespace :dev do
    desc 'Sample data for development environment'

    task prime: 'db:setup' do
      include FactoryBot::Syntax::Methods

      15.times do
        profile = %i[admin client].sample
        create(:user, profile: profile)
      end

      system_requirements = []
      %w[Basic Intermediate Advanced].each do |sr_name|
        system_requirements << create(:system_requirement, name: sr_name)
      end

      15.times do
        coupon_status = %w[active inactive].sample
        create(:coupon, status: coupon_status)
      end

      categories = []
      25.times do
        categories << create(:category, name: Faker::Game.unique.genre)
      end

      30.times do
        game_name = Faker::Game.unique.title
        status = %w[available unavailable].sample

        categories_count = rand(1..3)
        game_categories_ids = []
        categories_count.times { game_categories_ids << Category.all.sample.id }

        game = create(:game, system_requirement: system_requirements.sample)

        create(:product, name: game_name, status: status, category_ids: game_categories_ids, productable: game)
      end

      50.times do
        game = Game.all[0..5].sample
        status = %i[available in_use inactive].sample
        platform = %i[steam battle_net origin].sample

        create(:license, status: status, platform: platform, game: game)
      end
    end
  end
end
