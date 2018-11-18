# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount Ckeditor::Engine => '/ckeditor'

  devise_for :users
  root "pages#home"
  get 'pages/home', to: 'pages#home'

  resources :recipes do
    resources :comments, only: [:create]
    member do
      post 'like'
    end
  end

  get 'guests', to: 'guests#index'

  resources :chefs, except: [:new]
  resources :ingredients, except: [:destroy]
  resources :messages, only: [:create]
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
end
