# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :dummy_models

  namespace :cached do
    resources :dummy_models, only: :show, param: :slug
  end

  namespace :cached_defaults do
    resources :dummy_models, only: %i[show index]
  end

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
    resources :dummy_models, only: %i[show edit update destroy], param: :slug
  end

  namespace :html_finder do
    resources :dummy_models, only: %i[new show edit update destroy], param: :slug
  end

  namespace :block_finder do
    resources :dummy_models, only: %i[show edit update destroy], param: :slug
  end

  namespace :scoped do
    resources :dummy_models, only: :index
  end

  namespace :unpaginated_scoped do
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

  namespace :redirect do
    resources :dummy_models, only: %i[create destroy]
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

  namespace :block_redirect do
    resources :dummy_models, only: %i[show destroy]
  end

  namespace :block_json do
    resources :dummy_models, only: %i[index show new]
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

  namespace :nested_route do
    resources :classrooms, only: [], param: :slug do
      resources :dummy_models, param: :slug, only: %i[show create destroy]
    end
  end
end
