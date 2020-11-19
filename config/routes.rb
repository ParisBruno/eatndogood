# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  get 'reservation/create'

  #get '/'

  # resources :questions
  # resources :allergens

  mount Ckeditor::Engine => '/ckeditor'

  # devise_for :users
  root "pages#welcome"
  get 'pages/welcome', to: 'pages#welcome'
  # get '/live', to: 'pages#welcome'

  get '/recipes/ask-question', to: "recipes#email_question", as: "askquestion"

  # resources :recipes do
  #   resources :comments, only: [:create]
  #   member do
  #     post 'like'
  #   end
  # end

  #woocommerce api
  get '/fetchapi', to: "login#fetchapi"
  get '/api/forgotpasswordwp', to: "login#forgotpasswordwp"
  get '/api/deleteuserwp', to: "login#deleteuserwp"
  get '/api/checkuserinrorapp', to: "login#checkuserinrorapp"
  get '/api/updateplaninrorapp', to: "login#updateplaninrorapp"
  #end woocommerce api

  get 'guests', to: 'guests#index'
  post 'sendUserEmailContent', to: 'guests#send_emails', :defaults => { :format => 'json' }
  get "signupguest" => "guests#new", :as=>"newguestwithoutid"
  get "newguest/:id/:email", to: "guests#new", as: "newguest"
  post 'guests/create',to: "guests#create", as: 'guestCreation'
  delete 'guest/:id', to: 'guests#destroy', as: "destroy_guest"

  post 'line_items/:id/add' => "carts#add_quantity", as: "line_item_add"
  post 'line_items/:id/reduce' => "carts#reduce_quantity", as: "line_item_reduce"
  post 'line_items' => "line_items#create"
  get 'line_items/:id' => "line_items#show", as: "line_item"
  delete 'line_items/:id' => "carts#destroy_item"

  # resources :chefs #, except: [:new]
  # resources :ingredients, except: [:destroy]
  # resources :styles, except: [:destroy]
  # resources :messages, only: [:create]
  # resources :reservations, only: [:new, :create]
  # resources :pages do
  #   collection do
  #     post 'welcome/edit'
  #     post 'about/edit'
  #     get 'welcome', to: 'welcome'
  #     get 'about',   to: 'about'
  #   end
  # end
  mount ActionCable.server => '/cable'

  # get '/chat', to: 'chatrooms#show'

  get ':app', to: 'pages#welcome', as: "user_welcome"
  scope ':app', as: 'app' do
    authenticate :app_user do
      mount Sidekiq::Web => '/sidekiq'
    end
    devise_for :users
    get '/', to: 'pages#welcome'
    get 'add_coupon', to: 'carts#add_coupon'
    get 'return_stripe', to: 'orders#return_stripe'
    resources :autosaves, only: %i[index create]
    resources :guests, only: %i[index send_emails]
    resources :chefs
    resources :questions
    resources :allergens
    resources :recipes do
      resources :comments, only: [:create]
      member do
        post 'like'
      end
    end
    # to change
    # resources :chefs #, except: [:new]
    resources :ingredients
    resources :styles
    resources :messages, only: [:create]
    resources :reservations, only: [:new, :create]
    resources :pages do
      member do
        get 'preview'
      end
      collection do
        post 'welcome/edit'
        post 'about/edit'
        get 'welcome', to: 'welcome'
        get 'about',   to: 'about'
      end
    end
    resources :carts, only: %i[show destroy]
    resources :orders
  end
  resources :charges
  post 'check-coupon', to: 'carts#check_coupon'
  post 'check-delivery', to: 'carts#check_delivery'
  post 'check-tip', to: 'carts#check_tip'
  post 'paypal_create_payment', to: 'orders#paypal_create_payment', as: "paypal_create_payment"
  post 'paypal_execute_payment', to: 'orders#paypal_execute_payment', as: "paypal_execute_payment"
end
