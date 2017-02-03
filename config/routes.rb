require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  resources :favorites,      only:   [:index, :create, :destroy]
  resources :links,          only:   [:index, :show] do
    get  '/share/:network', to: 'links#share',      as: 'share'
  end

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  get '/legal', to: 'pages#legal'
  root to: 'pages#home'
end
