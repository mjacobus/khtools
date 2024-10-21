# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  if Rails.env.development?
    get '/dev/login', to: 'development#login'
  end

  get '/discursos', to: 'public#public_talks'
  get '/config', to: 'config#index'

  namespace :field_service do
    resources :campaigns do
      resources :assignments, controller: :campaign_assignments, only: %i[index]
    end
  end

  namespace :congregation do
    resources :publishers
  end

  namespace :public_talks do
    resources :congregations
    resources :speakers
    resources :talks
  end

  namespace :meeting_attendance do
    resources :meetings do
      resources :simple_counter_attendees, controller: :simple_counter
    end
  end

  # TODO: Move to field service namespace
  namespace :territories do
    resources :territories, only: [:show] do
      resources :assignments
    end
    resources :regular_territories do
      get :printable, defaults: { format: :pdf }
      get '/token/:token', action: 'public_show'
      resources :assignments
      resources :locations
    end
    resources :phone_list_territories do
      resources :assignments
      member do
        get :xls
        get :pdf, defaults: { format: :pdf }
        post :create_token
      end
    end
    resources :apartment_building_territories do
      resources :assignments
    end
    resources :commercial_territories do
      resources :assignments
      resources :contacts
    end
    resources :phone_lists
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
