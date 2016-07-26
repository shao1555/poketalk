Rails.application.routes.draw do
  # You can have the root of your site routed with "root"
  root 'welcome#index'

  resources :rooms, only: %i(index show)
  resources :messages, only: %i(index create)
end
