# frozen_string_literal: true

require 'spec_helper'

class UnpoliceableThing; end

class UnpoliceableThingsController
  extend SimpleCrudController
end

class BaseWithDefaultsController
  extend SimpleCrudController
  simple_crud_defaults authorize: false, authenticate: false, authenticate_headers: true
end

class InheritingController < BaseWithDefaultsController
end

describe SimpleCrudController do
  describe '.check_policies' do
    it 'returns when a matching policy exists' do
      expect { DummyModelsController.check_policies(authorize: true) }.not_to raise_error
    end

    it 'raises when no matching policy exists' do
      expect do
        UnpoliceableThingsController.check_policies(authorize: true)
      end.to raise_error(ArgumentError)
    end
  end

  describe '.simple_crud_defaults' do
    it 'applies to parameters_with_defaults', :aggregate_failures do
      params = BaseWithDefaultsController.parameters_with_defaults({})
      expect(params[:authorize]).to be false
      expect(params[:authenticate]).to be false
      expect(params[:authenticate_headers]).to be true
    end

    it 'are inherited by subclasses', :aggregate_failures do
      params = InheritingController.parameters_with_defaults({})
      expect(params[:authorize]).to be false
      expect(params[:authenticate]).to be false
      expect(params[:authenticate_headers]).to be true
    end

    it 'can be overridden per action', :aggregate_failures do
      params = InheritingController.parameters_with_defaults(authorize: true)
      expect(params[:authorize]).to be true
      expect(params[:authenticate]).to be false
      expect(params[:authenticate_headers]).to be true
    end

    it 'does not affect unrelated controllers', :aggregate_failures do
      params = DummyModelsController.parameters_with_defaults({})
      expect(params[:authorize]).to be true
      expect(params[:authenticate]).to be true
      expect(params[:authenticate_headers]).to be true
    end
  end

  describe '.check_serializer' do
    it 'returns when the serializer option is blank' do
      expect { DummyModelsController.check_serializer({}) }.not_to raise_error
    end

    it 'returns when a matching serializer exists' do
      expect do
        DummyModelsController.check_serializer(serializer: 'DummyModelSerializer')
      end.not_to raise_error
    end

    it 'raises when no matching serializer exists' do
      expect do
        DummyModelsController.check_serializer(serializer: 'NonExistentSerializer')
      end.to raise_error(ArgumentError)
    end
  end
end
