# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get '/starter', to: 'starter#index', as: 'starter'
  # Defines the root path route ("/")
  # root "articles#index"
end
