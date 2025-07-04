require 'sidekiq/web'

Rails.application.routes.draw do
  get 'dashboard/index'
  devise_for :users
  resources :monitored_urls
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end
  unauthenticated do
    root to: 'welcome#index', as: :unauthenticated_root
  end

  get '/dashboard', to: 'dashboard#index', as: :dashboard

  authenticate :user, lambda { |u| u.admin? rescue false } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/metrics', to: 'metrics#index'
  mount HealthCheck::Engine, at: "/healthcheck"

  # Defines the root path route ("/")
  # root "posts#index"
end
