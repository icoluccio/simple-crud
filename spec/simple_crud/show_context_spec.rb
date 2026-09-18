# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::ShowContext do
  describe '#find_record' do
    it 'raises when a custom finder returns something other than a record' do
      finder = ->(_params) { DummyModel.where(name: 'x') }
      ctx = described_class.new(double(params: {}), DummyModel, { finder: finder, authorize: false })
      expect { ctx.send(:find_record) }
        .to raise_error(ActiveRecord::RecordNotFound, /must return a single record/)
    end

    it 'raises not found when owned_by has no owner to scope the lookup to' do
      ctx = described_class.new(double(params: { id: 1 }), DummyModel, { owned_by: :dummy_models, authorize: false })
      expect { ctx.send(:find_record) }.to raise_error(ActiveRecord::RecordNotFound, /no owner/)
    end
  end
end
