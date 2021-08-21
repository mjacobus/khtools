# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'

  if Rails.env.development?
    get '/dev/login', to: 'development#login'
  end
end
