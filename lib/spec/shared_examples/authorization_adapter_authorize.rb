# frozen_string_literal: true

RSpec.shared_examples 'authorization adapter #authorize' do |record_class, denied_error|
  it 'passes for a record the adapter allows' do
    expect { adapter.authorize(controller, record_class.new(1)) }.not_to raise_error
  end

  it 'raises for a record the adapter denies' do
    expect { adapter.authorize(controller, record_class.new(2)) }.to raise_error(denied_error)
  end
end
