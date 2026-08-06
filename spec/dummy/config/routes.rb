# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :dummy_models

  namespace :without_pagination do
    resources :dummy_models, only: :index
  end

  namespace :html do
    resources :dummy_models, only: :index
  end

  namespace :block do
    resources :dummy_models, only: :index
  end

  namespace :finder do
    resources :dummy_models, only: %i[show update destroy], param: :slug
  end

  namespace :scoped do
    resources :dummy_models, only: :index
  end

  namespace :strict do
    resources :dummy_models, only: %i[create update]
  end
end
