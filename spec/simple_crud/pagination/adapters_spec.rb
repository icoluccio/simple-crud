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
end
