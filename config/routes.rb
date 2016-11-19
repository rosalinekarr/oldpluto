Rails.application.routes.draw do
  devise_for :users

  resources :advertisements, except: [:show, :edit, :update]

  resources :links, only: [:index, :show] do
    get  '/share/:network', to: 'links#share',      as: 'share'
    post '/favorite',       to: 'links#favorite',   as: 'favorite'
    post '/unfavorite',     to: 'links#unfavorite', as: 'unfavorite'
  end
  get '/favorites', to: 'links#favorites'

  get '/legal', to: 'pages#legal'
  root to: 'pages#home'
end
