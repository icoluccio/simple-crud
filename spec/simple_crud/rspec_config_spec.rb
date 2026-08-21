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

    it 'omits owner params when there is no owner association', :aggregate_failures do
      with_config_override(:owner_association, nil) do
        expect(owner_params).to eq({})
        expect(model_attributes).to eq({})
      end
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

    it 'falls back to global config when no metadata overrides' do
      expect(setting(:finder_key)).to eq(:slug)
    end

    it 'defaults model_attributes to the owner association and current user' do
      expect(model_attributes).to eq(user: current_user)
    end

    describe 'with simple_crud metadata',
             simple_crud: { finder_key: :token, model_attributes: -> { { overridden: true } } } do
      it 'prefers metadata for overridden settings' do
        expect(setting(:finder_key)).to eq(:token)
      end

      it 'still falls back to global config for the rest' do
        expect(required_attribute).to eq(:name)
      end

      it 'resolves model_attributes from metadata in the example context' do
        expect(model_attributes).to eq(overridden: true)
      end
    end
  end
end
