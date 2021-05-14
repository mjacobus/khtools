# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  if Rails.env.development?
    get '/dev/login', to: 'development#login'
  end

  namespace :meeting_attendance do
    resources :meetings do
      resources :simple_counter_attendees, controller: :simple_counter
    end
  end

  resources :users, only: %i[index] do
    member do
      patch :enable
      patch :disable
      patch :grant_admin
      patch :revoke_admin
    end
  end

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'
end
