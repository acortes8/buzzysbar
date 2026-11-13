Rails.application.routes.draw do
  resources :drinks
  resource :log, only: %i[ new create ]
  resources :occasions do
    resources :tastings, only: %i[ edit update destroy ]
    resources :photos, only: %i[ create update destroy ], module: :occasions
  end
  resources :places
  resources :people
  resources :users
  resource :session
  resource :demo, only: :create
  resources :passwords, param: :token
  resources :recipes
  resources :books, only: %i[ index show edit update destroy ]
  resources :cocktails, only: %i[ index show ]
  # Recipes were called beverages, and were public, until phase 4. Old links go
  # to the public pages, where an unpublished recipe is a 404.
  get "beverages", to: redirect("/cocktails")
  get "beverages/:id", to: redirect("/cocktails/%{id}")
  resources :rankings, only: %i[ index show ]
  resources :bars, only: %i[ index show ]
  root "occasions#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
