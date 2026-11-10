# frozen_string_literal: true

Rails.application.routes.draw do
  ActiveAdmin.routes(self)

  # config/routes.rb
  get '/up', to: proc { [200, {}, ['OK']] }
  get '/version', to: 'version#show'

  root to: 'home#index'

  if Rails.env.development?
    get '/dev/login', to: 'development#login'
  end

  get '/discursos', to: 'public#default_public_talks'
  get '/discursos/:account_id', to: 'public#public_talks', as: :public_talks
  get '/config', to: 'config#index'

  namespace :field_service do
    resources :campaigns do
      resources :assignments, controller: :campaign_assignments, only: %i[index]
    end
  end

  post '/finance/telegram/:account_id', to: 'finance/telegram_webhooks#create'

  namespace :finance do
    resources :documents, only: %i[index edit update] do
      member do
        get :payment
        post :confirm
        post :discard
        get :file
        patch :payment, action: :update_payment
        post :cash_received
        post :cash_pix
      end
      collection do
        get :archive
        post :archive, action: :move_to_archive
        post :meeting_exceptions, action: :create_meeting_exception
        delete :meeting_exceptions, action: :destroy_meeting_exception
      end
    end
    resources :reminders, except: :show do
      post :done, on: :member
    end
    resources :integrations, only: %i[show update], param: :section do
      post :members, on: :member
    end
    resource :drive_connection, only: %i[show] do
      get :callback
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
      resources :locations do
        member do
          post :mark_contacted
        end
      end
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

  namespace :reports do
    resources :territory_assignments, only: %i[index]
  end

  resources :users, only: %i[index edit update]

  get '/auth/:provider/callback', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy'
end
