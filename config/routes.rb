Rails.application.routes.draw do
  devise_for :users
  resources :channels
  root to: "home#index"
end
