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

  it 'paginates with Kaminari' do
    SimpleCrud::Config.pagination_adapter = SimpleCrud::Pagination::KaminariAdapter.new

    get '/dummy_models', params: { page: 2, per_page: 5 }, headers: auth_headers

    expect(response.parsed_body.size).to eq(5)
  end

  it 'paginates with will_paginate' do
    SimpleCrud::Config.pagination_adapter = SimpleCrud::Pagination::WillPaginateAdapter.new

    get '/dummy_models', params: { page: 2, per_page: 5 }, headers: auth_headers

    expect(response.parsed_body.size).to eq(5)
  end

  it 'paginates with Pagy' do
    SimpleCrud::Config.pagination_adapter = SimpleCrud::Pagination::PagyAdapter.new

    get '/dummy_models', params: { page: 2, limit: 5 }, headers: auth_headers

    expect(response.parsed_body.size).to eq(5)
  end
end
