Rails.application.routes.draw do
  resources :ads, only: [:index, :create, :new]
  resources :settings, only: [:edit, :update], controller: 'home'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  root to: "home#index"
end
