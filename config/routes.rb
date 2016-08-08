Rails.application.routes.draw do
  devise_for :users

  get '/:feed_id', to: 'links#index', as: :feed

  root to: 'links#index'
end
