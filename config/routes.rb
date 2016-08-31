Rails.application.routes.draw do
  devise_for :users

  resources :links, only: :show

  root to: 'links#index'
end
