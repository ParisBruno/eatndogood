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
    get 'add_additional_params', to: 'carts#add_additional_params'
    get 'return_stripe', to: 'orders#return_stripe'
    post 'coupon_codes', to: "chefs#add_coupon", as: "add_coupon_codes"
    delete 'coupon_codes/:code_id', to: "chefs#destroy_coupon", as: "coupon_codes"
    post 'fundrasing_codes', to: "chefs#add_fundrasing", as: "add_fundrasing_codes"
    delete 'fundrasing_codes/:code_id', to: "chefs#destroy_fundrasing", as: "fundrasing_codes"
    get 'recipe_drafts', to: "recipes#drafts", as: "recipe_drafts"
    resources :autosaves, only: %i[index create]
    resources :guests, only: %i[index send_emails]
    resources :chefs
    resources :questions
    resources :allergens do
      get 'table', on: :collection
    end
    resources :recipes do
      resources :comments, only: [:create]
      member do
        post 'like'
      end
    end
    # to change
    # resources :chefs #, except: [:new]
    resources :ingredients do
      get 'table', on: :collection
    end
    resources :styles do
      get 'table', on: :collection
    end
    resources :messages, only: [:create] do
      get 'managers', on: :collection
      post 'send_email', on: :collection
    end
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
    resources :gift_cards, only: %i[new create]
    resources :reports, only: %i[index]
    post 'recipe-sales', to: 'reports#recipe_sales', as: "recipe_sales"
    post 'category-sales', to: 'reports#category_sales', as: "category_sales"
    get 'new-order', to: 'orders#new_staff_order', as: "new_staff_order"
    post 'create-staff-order', to: 'orders#create_staff_order', as: "create_staff_order"
    get 'managers', to: 'chefs#managers', as: "managers"
    get 'staff', to: 'chefs#staff', as: "staff"
  end
  resources :charges
  post 'check-stripe-coupon', to: 'carts#check_stripe_coupon'
  post 'check-coupon', to: 'carts#check_coupon'
  post 'check-fundrasing', to: 'carts#check_fundrasing'
  post 'check-delivery', to: 'carts#check_delivery'
  post 'check-tip', to: 'carts#check_tip'
  post 'paypal_create_payment', to: 'orders#paypal_create_payment', as: "paypal_create_payment"
  post 'paypal_execute_payment', to: 'orders#paypal_execute_payment', as: "paypal_execute_payment"
end
