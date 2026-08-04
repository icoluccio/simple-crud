# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :dummy_models

  namespace :without_pagination do
    resources :dummy_models, only: :index
  end
end
