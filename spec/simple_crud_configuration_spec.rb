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

    {
      authorization_adapter: [SimpleCrud::Authorization::PunditAdapter, 'the Pundit default'],
      pagination_adapter: [SimpleCrud::Pagination::WorPaginateAdapter, 'the wor-paginate default']
    }.each do |adapter_name, (adapter_class, default_description)|
      it "lets a custom #{adapter_name.to_s.sub('_adapter', '')} adapter replace #{default_description}" do
        original_adapter = SimpleCrud::Config.public_send(adapter_name)
        custom_adapter = instance_double(adapter_class)

        described_class.configure { |config| config.public_send("#{adapter_name}=", custom_adapter) }
        expect(SimpleCrud::Config.public_send(adapter_name)).to eq(custom_adapter)

        SimpleCrud::Config.public_send("#{adapter_name}=", original_adapter)
      end
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

    it 'defaults #policy_scope to the full relation' do
      expect(adapter.policy_scope(nil, DummyModel).to_sql).to eq(DummyModel.all.to_sql)
    end
  end

  describe SimpleCrud::Pagination::Adapter do
    subject(:adapter) { IncompletePaginationAdapter.new }

    it 'requires #paginate to be implemented' do
      expect { adapter.paginate(nil, nil, nil) }.to raise_error(NotImplementedError)
    end

    it 'requires #paginated_records to be implemented' do
      expect { adapter.paginated_records(nil, nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
