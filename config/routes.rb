# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root to: 'home#index'

  if Rails.env.development?
    get '/dev/login', to: 'development#login'
  end

  get '/discursos', to: 'public#public_talks'

  namespace :field_service do
    resources :campaigns do
      resources :assignments, controller: :campaign_assignments, only: %i[index edit update] do
        collection do
          post 'create_assignments/:territory_type', action: :create_assignments, as: :create
        end
      end
    end
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
    resources :regular_territories
    resources :phone_list_territories do
      member do
        get :xls
      end
    end
    resources :apartment_building_territories
    resources :commercial_territories do
      resources :contacts
    end
    resources :phone_lists do
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
