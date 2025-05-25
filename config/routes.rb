Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/swagger'
  mount Rswag::Api::Engine => '/swagger'
  namespace :api do
    resources :workouts do
      collection do
        get :future
      end
      member do
        put :sign_up
      end
    end
    resources :clubs do
      member do
        delete :admin, to: 'delete_admin'
        delete :coach, to: 'delete_coach'
  
        post :admin, to: 'add_admin'
        post :coach, to: 'add_coach'
      end
    end

    resources :users, param: :uuid do
      collection do
        post :authorization
        get :get_me
      end
      member do
        get 'image', to: 'get_user_image'
        put 'image', to: 'update_user_image'
        get :last_shot
        post :find_gun_by_shoot

        resources :guns, module: :users, controller: 'guns' do
          member do
            get 'sound'
            put 'sound', to: 'update_sound'
          end
        end
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
