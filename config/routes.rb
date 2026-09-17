Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root "dashboard#index"

    resources :alcohol_checks, only: [:index]
  end

  root "dashboard#index"

  resources :alcohol_checks, only: [:create]
end
