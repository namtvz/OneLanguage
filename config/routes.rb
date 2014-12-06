Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      omniauth_callbacks: :omniauth_callbacks
    }
    
  authenticated :user do
    root :to => 'home#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')

  resources :channels

end
