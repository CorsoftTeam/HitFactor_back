Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/swagger'
  mount Rswag::Api::Engine => '/swagger'
  namespace :api do
    resources :users do
      collection do
        post :authorization
        get :get_me
      end
      member do
        get 'image', to: 'get_user_image'
        get :guns
        get 'guns/:gun_id/sound', to: 'get_gun_sound'
        post :guns, to: 'create_gun'
        put 'image', to: 'update_user_image'
        put 'guns/:gun_id', to: 'update_gun'
        put 'guns/:gun_id/sound', to: 'update_gun_sound'
        delete 'guns/:gun_id', to: 'delete_gun'
        get 'guns/:gun_id', to: 'gun'
        post 'find_gun_by_shoot', to: 'find_gun_by_shoot'
        get 'last_shot', to: 'last_shot'
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'api/authorization', to: 'api/users#authorization'

  # Defines the root path route ("/")
  # root "posts#index"
end
