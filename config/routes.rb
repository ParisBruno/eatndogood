# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  get 'reservation/create'

  #get '/'

  resources :questions
  resources :allergens
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users
  root "pages#welcome"
  get 'pages/welcome', to: 'pages#welcome'
  get '/live', to: 'pages#welcome'

  get '/recipes/ask-question', to: "recipes#email_question", as: "askquestion"

  resources :recipes do
    resources :comments, only: [:create]
    member do
      post 'like'
    end
  end

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
  delete 'guest', to: 'guests#destroy', as: "destroy_guest"



  resources :chefs #, except: [:new]
  resources :ingredients, except: [:destroy]
  resources :styles, except: [:destroy]
  resources :messages, only: [:create]
  resources :reservations, only: [:new, :create]
  resources :pages do
    collection do
      post 'welcome/edit'
      post 'about/edit'
      get 'welcome', to: 'welcome'
      get 'about',   to: 'about'
    end
  end
  mount ActionCable.server => '/cable'

  get '/chat', to: 'chatrooms#show'

  get ':user', to: 'pages#welcome'
  scope ':user' do
    get '/', to: 'pages#welcome'
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
  end

end
