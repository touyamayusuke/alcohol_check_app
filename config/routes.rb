Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    root "dashboard#index"

    resources :alcohol_checks, only: [ :index ]
    resources :users, only: [ :index, :new, :create, :edit, :update ]
  end

  root "dashboard#index"

  resources :alcohol_checks, only: [ :create ]
end
