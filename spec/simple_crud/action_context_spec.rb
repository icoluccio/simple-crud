# frozen_string_literal: true

require 'spec_helper'

describe SimpleCrud::ActionContext do
  let(:ctx) { described_class.new(double, double, {}) }

  it 'raises NotImplementedError when run is not overridden' do
    expect { ctx.send(:run) }.to raise_error(NotImplementedError)
  end

  it 'raises NotImplementedError when action_name is not overridden' do
    expect { ctx.send(:action_name) }.to raise_error(NotImplementedError)
  end
end
