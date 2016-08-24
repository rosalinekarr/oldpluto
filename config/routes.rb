Rails.application.routes.draw do
  devise_for :users

  get '/:id', to: 'links#show', as: 'link'

  root to: 'links#index'
end
