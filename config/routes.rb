Rails.application.routes.draw do
  resources :fb_ads, path: 'ads', only: [:index, :new, :create]
  get '/ads/:id/run', to: 'fb_ads#run', as: :run_fb_ad

  resources :settings, only: [:edit, :update], controller: 'home'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  get 'privacy', to: 'home#privacy'

  root to: "home#index"
end
