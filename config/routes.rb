require 'sidekiq/web'

Rails.application.routes.draw do
  get 'dashboard/index'
  resources :monitored_urls
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/health", to: proc { [200, {}, ['OK']] }


  # Root route - no authentication needed
  root to: 'dashboard#index'

  get '/dashboard', to: 'dashboard#index', as: :dashboard

  # Sidekiq web interface - accessible without authentication
  mount Sidekiq::Web => '/sidekiq'

  get '/metrics', to: 'metrics#index'
  # mount HealthCheck::Engine, at: "/healthcheck"

  # Defines the root path route ("/")
  # root "posts#index"
end
