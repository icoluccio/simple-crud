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

  namespace :scoped_params do
    resources :dummy_models, only: :index
  end

  namespace :strict do
    resources :dummy_models, only: %i[create update]
  end

  namespace :html_show do
    resources :dummy_models, only: :show
  end

  namespace :block_show do
    resources :dummy_models, only: :show
  end

  namespace :html_new do
    resources :dummy_models, only: :new
  end

  namespace :block_new do
    resources :dummy_models, only: :new
  end

  namespace :html_create do
    resources :dummy_models, only: :create
  end

  namespace :block_create do
    resources :dummy_models, only: :create
  end

  namespace :html_update do
    resources :dummy_models, only: :update
  end

  namespace :html_destroy do
    resources :dummy_models, only: :destroy
  end

  namespace :block_destroy do
    resources :dummy_models, only: :destroy
  end

  namespace :built do
    resources :dummy_models, only: %i[new create]
  end

  namespace :redirect_auth do
    resources :dummy_models, only: :index
  end

  namespace :html_scoped do
    resources :dummy_models, only: :index
  end

  namespace :nested do
    resources :dummy_models, only: %i[create update]
  end

  namespace :invalid_status do
    resources :dummy_models, only: :create
  end
end
