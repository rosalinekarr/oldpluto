Rails.application.routes.draw do
  get '/:feed_id', to: 'links#index', as: :feed
  root to: 'links#index'
end
