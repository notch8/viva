# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users, :path => '', :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" }, :sign_out_via => [ :get, :delete ]

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
      # uncomment the below instead to simulate being logged in
      # root 'home#index', as: :unauthenticated_root
    end
  end

  get '/settings', to: 'settings#index', as: 'settings'

  resources :questions, only: :index
end
