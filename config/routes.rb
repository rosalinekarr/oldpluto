Rails.application.routes.draw do
  devise_for :users

  resources :links, only: [:index, :show] do
    get '/share/:network', to: 'links#share', as: 'share'
  end

  get '/legal', to: 'pages#legal'
  root to: 'pages#home'
end
