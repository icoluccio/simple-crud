# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::RSpec do
  let(:config) { SimpleCrud::RSpec::Config.instance }

  describe '.configure' do
    it 'yields the config instance' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(config)
    end
  end

  describe SimpleCrud::RSpec::Config do
    it 'defaults the owner and finder settings', :aggregate_failures do
      expect(config.owner_association).to eq(:user)
      expect(config.finder_key).to eq(:slug)
    end

    it 'defaults the model validation settings', :aggregate_failures do
      expect(config.required_attribute).to eq(:name)
      expect(config.required_error).to eq("Name can't be blank")
    end

    it 'defaults the html and status settings', :aggregate_failures do
      expect(config.unauthenticated_status).to eq(:unauthorized)
      expect(config.assert_html_template).to be true
    end

    it 'defaults to flat params', :aggregate_failures do
      expect(config.params_key).to be_nil
      expect(body_params(name: 'x')).to eq(name: 'x')
    end

    it 'lets settings be overridden and restored', :aggregate_failures do
      original = config.required_attribute

      SimpleCrud::RSpec.configure { |c| c.required_attribute = :title }
      expect(config.required_attribute).to eq(:title)

      SimpleCrud::RSpec.configure { |c| c.required_attribute = original }
      expect(config.required_attribute).to eq(:name)
    end
  end

  describe SimpleCrud::RSpec::Helpers do
    it 'resolves plain settings as-is' do
      expect(resolve(config.owner_association)).to eq(:user)
    end

    it 'resolves callable settings in the example context' do
      original = config.required_attribute

      SimpleCrud::RSpec.configure { |c| c.required_attribute = -> { :title } }
      expect(required_attribute).to eq(:title)

      SimpleCrud::RSpec.configure { |c| c.required_attribute = original }
    end
  end
end
