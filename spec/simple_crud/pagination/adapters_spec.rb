# frozen_string_literal: true

require 'spec_helper'
require 'simple_crud/pagination/kaminari_adapter'
require 'simple_crud/pagination/will_paginate_adapter'
require 'simple_crud/pagination/pagy_adapter'

describe 'pagination adapters', type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { Devise::JWT::TestHelpers.auth_headers({}, user) }

  before do
    create_list(:dummy_model, 15, user: user)
    # Index authorizes against a blank klass.new (no owner), so the real
    # ownership-based policy can never pass here.
    allow(DummyModelPolicy).to receive(:new).and_return(instance_double(DummyModelPolicy, index?: true))
  end

  around do |example|
    original_adapter = SimpleCrud::Config.pagination_adapter
    example.run
    SimpleCrud::Config.pagination_adapter = original_adapter
  end

  {
    'Kaminari' => [SimpleCrud::Pagination::KaminariAdapter, { per_page: 5 }],
    'will_paginate' => [SimpleCrud::Pagination::WillPaginateAdapter, { per_page: 5 }],
    'Pagy' => [SimpleCrud::Pagination::PagyAdapter, { limit: 5 }]
  }.each do |name, (adapter_class, pagination_params)|
    it "paginates with #{name}" do
      SimpleCrud::Config.pagination_adapter = adapter_class.new

      get '/dummy_models', params: { page: 2 }.merge(pagination_params), headers: auth_headers

      expect(response.parsed_body.size).to eq(5)
    end
  end

  describe 'Kaminari edge cases' do
    before { SimpleCrud::Config.pagination_adapter = SimpleCrud::Pagination::KaminariAdapter.new }

    # Offset math must not trust string params: "5" * 2 == "55".
    it 'paginates past page 2 when params arrive as strings' do
      get '/dummy_models', params: { page: '3', per_page: '5' }, headers: auth_headers

      expected_ids = DummyModel.offset(10).limit(5).pluck(:id)
      expect(response.parsed_body.map { |record| record['id'] }).to match_array(expected_ids)
    end

    context 'with Kaminari.config.max_per_page set' do
      let!(:original_max_per_page) { Kaminari.config.max_per_page }

      before do
        Kaminari.config.max_per_page = 8
      end

      after { Kaminari.config.max_per_page = original_max_per_page }

      it 'caps per_page at the configured ceiling' do
        get '/dummy_models', params: { page: 1, per_page: '100' }, headers: auth_headers

        expect(response.parsed_body.size).to eq(8)
      end
    end

    it 'falls back to page 1 for non-numeric page params' do
      get '/dummy_models', params: { page: 'abc', per_page: '5' }, headers: auth_headers

      expect(response.parsed_body.size).to eq(5)
    end
  end
end
