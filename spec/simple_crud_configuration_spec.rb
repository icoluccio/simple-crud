# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/authorization/pundit_adapter'
require 'simple_crud/pagination/wor_paginate_adapter'

class IncompleteAuthorizationAdapter
  include SimpleCrud::Authorization::Adapter
end

class IncompletePaginationAdapter
  include SimpleCrud::Pagination::Adapter
end

describe SimpleCrud do
  describe '.configure' do
    it 'yields SimpleCrud::Config' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(SimpleCrud::Config)
    end

    it 'lets a custom authorization adapter replace the Pundit default' do
      original_adapter = SimpleCrud::Config.authorization_adapter
      custom_adapter = instance_double(SimpleCrud::Authorization::PunditAdapter)

      described_class.configure { |config| config.authorization_adapter = custom_adapter }
      expect(SimpleCrud::Config.authorization_adapter).to eq(custom_adapter)

      SimpleCrud::Config.authorization_adapter = original_adapter
    end

    it 'lets a custom pagination adapter replace the wor-paginate default' do
      original_adapter = SimpleCrud::Config.pagination_adapter
      custom_adapter = instance_double(SimpleCrud::Pagination::WorPaginateAdapter)

      described_class.configure { |config| config.pagination_adapter = custom_adapter }
      expect(SimpleCrud::Config.pagination_adapter).to eq(custom_adapter)

      SimpleCrud::Config.pagination_adapter = original_adapter
    end
  end

  describe SimpleCrud::Authorization::Adapter do
    subject(:adapter) { IncompleteAuthorizationAdapter.new }

    it 'requires #authorize to be implemented' do
      expect { adapter.authorize(nil, nil) }.to raise_error(NotImplementedError)
    end

    it 'requires #policy_defined? to be implemented' do
      expect { adapter.policy_defined?(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe SimpleCrud::Pagination::Adapter do
    subject(:adapter) { IncompletePaginationAdapter.new }

    it 'requires #paginate to be implemented' do
      expect { adapter.paginate(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
