# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users, :path => '', :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" }, :sign_out_via => [ :get, :delete ]

  devise_scope :user do
    authenticated :user do
      root 'search#index', as: :authenticated_root
      get '/settings', to: 'settings#index', as: 'settings'
      patch '/settings/update', to: 'settings#update'
      get '/uploads', to: 'uploads#index', as: 'uploads'
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
      # uncomment the below instead to simulate being logged in
      # root 'search#index', as: :unauthenticated_root
    end
  end

end
