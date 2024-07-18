# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users, :path => '', :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" }, :sign_out_via => [ :get, :delete ]

  devise_scope :user do
    authenticated :user do
      # search page routes
      root 'search#index', as: :authenticated_root

      # Necessary for downloading the XML file from the search result.
      get '/(.:format)', to: 'search#index'

      # settings page routes
      get '/settings', to: 'settings#index', as: 'settings'
      patch '/settings/update', to: 'settings#update'
      patch '/settings/update-password', to: 'settings#update_password'
      # uploads page routes
      get '/uploads', to: 'uploads#index', as: 'uploads'
      post '/uploads', to: 'uploads#create'
      # bookmarks page routes
      delete 'bookmarks/destroy_all', to: 'bookmarks#destroy_all' # has to come before bookmarks#destroy
      post 'bookmarks', to: 'bookmarks#create'
      delete 'bookmarks/:id', to: 'bookmarks#destroy', as: 'bookmark'
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
      # uncomment the below instead to simulate being logged in
      # root 'search#index', as: :unauthenticated_root
    end
  end

end
