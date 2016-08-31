Rails.application.routes.draw do
  devise_for :users

  resources :links, only: :show do
    get '/share/:network', to: 'links#share', as: 'share'
  end

  root to: 'links#index'
end
