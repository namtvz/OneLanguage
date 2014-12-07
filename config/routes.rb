Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      omniauth_callbacks: :omniauth_callbacks,
      registrations: :registrations
    }

  devise_scope :user do
    put "users/upload_avatar", to: "registrations#upload_avatar"
  end

  authenticated :user do
    root :to => 'channels#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')

  resources :channels
  resources :attachments, only: [:create, :destroy]

  get '/search_languages' => 'home#search_languages'
  resources :invitations, only: [:show, :create]
end
