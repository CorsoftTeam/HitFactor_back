Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/swagger'
  mount Rswag::Api::Engine => '/swagger'
  namespace :api do
    resources :users do
      collection do
        post :authorization
        get :authorization
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
