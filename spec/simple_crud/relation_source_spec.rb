# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::RelationSource do
  after { SimpleCrud::Config.user_method = :current_user }

  let(:controller) { double(params: {}) }
  let(:source) { described_class.new(controller, DummyModel, parameters) }

  describe '#configured?' do
    it 'is true for owned_by' do
      expect(described_class.new(controller, DummyModel, { owned_by: :dummy_models })).to be_configured
    end

    it 'is true for parent' do
      expect(described_class.new(controller, DummyModel, { parent: :owner })).to be_configured
    end

    it 'is false when neither is set' do
      expect(described_class.new(controller, DummyModel, {})).not_to be_configured
    end
  end

  describe '#relation' do
    it 'is nil when neither option is set' do
      expect(described_class.new(controller, DummyModel, {}).relation).to be_nil
    end

    context 'with owned_by' do
      let(:parameters) { { owned_by: :dummy_models } }

      it 'resolves the association on the user' do
        models = DummyModel.none
        allow(controller).to receive(:current_user).and_return(double(dummy_models: models))

        expect(source.relation).to eq(models)
      end

      it 'is nil without a current user' do
        expect(source.relation).to be_nil
      end

      it 'resolves the user via overridden Config.user_method' do
        SimpleCrud::Config.user_method = :current_admin
        models = DummyModel.none
        allow(controller).to receive(:current_admin).and_return(double(dummy_models: models))

        expect(source.relation).to eq(models)
      end
    end

    context 'with parent' do
      let(:parameters) { { parent: :owner } }

      it 'prefers a controller method over an ivar' do
        parent = double(dummy_models: DummyModel.none)
        allow(controller).to receive(:owner).and_return(parent)

        expect(source.relation).to eq(DummyModel.none)
      end

      it 'falls back to the ivar when there is no method' do
        parent = double(dummy_models: DummyModel.none)
        controller.instance_variable_set(:@owner, parent)

        expect(source.relation).to eq(DummyModel.none)
      end

      it 'runs a Proc parent in controller context' do
        parent = double(dummy_models: DummyModel.none)
        allow(controller).to receive(:owner).and_return(parent)
        proc_source = described_class.new(controller, DummyModel, { parent: -> { owner } })

        expect(proc_source.relation).to eq(DummyModel.none)
      end

      it 'is nil when the parent resolves to nil' do
        controller.instance_variable_set(:@owner, nil)

        expect(source.relation).to be_nil
      end

      it 'derives the association from the model' do
        parent = double
        controller.instance_variable_set(:@owner, parent)
        allow(parent).to receive(:dummy_models).and_return(DummyModel.none)

        expect(source.relation).to eq(DummyModel.none)
      end

      it 'honors parent_association:' do
        models = DummyModel.none
        controller.instance_variable_set(:@owner, double(special: models))
        source = described_class.new(controller, DummyModel, { parent: :owner, parent_association: :special })

        expect(source.relation).to eq(models)
      end
    end
  end

  describe '#relation!' do
    let(:parameters) { { owned_by: :dummy_models } }

    it 'raises not found when the owner cannot be resolved' do
      expect { source.relation! }.to raise_error(ActiveRecord::RecordNotFound, /no owner for dummy_models/)
    end
  end

  describe '#user' do
    let(:parameters) { {} }

    it 'returns nil when the controller has no user method' do
      expect(source.user).to be_nil
    end
  end

  describe 'unresolvable parent' do
    let(:parameters) { { parent: :owner } }

    it 'raises when the parent is neither a method nor an ivar' do
      expect { source.relation }.to raise_error(ArgumentError, /neither a controller method nor an @owner ivar/)
    end
  end
end
