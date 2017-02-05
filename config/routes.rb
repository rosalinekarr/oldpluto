require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  resources :favorites,      only:   [:index, :create, :destroy]
  resources :links,          only:   [:index, :show] do
    get  '/share/:network', to: 'links#share',      as: 'share'
  end

  # Admin only routes
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/legal', to: 'pages#legal'
  root to: 'links#index'
end
