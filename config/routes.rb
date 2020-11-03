Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth/v1/user'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :admin do
    namespace :v1 do
      get "home" => "home#index"
    end
  end

  namespace :storefront do
    namespace :v1 do

    end
  end
end
