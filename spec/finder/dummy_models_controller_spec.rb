# frozen_string_literal: true

require 'spec_helper'

describe Finder::DummyModelsController, type: :controller do
  include_examples 'simple crud for edit'
  include_examples 'simple crud for show with finder'
  include_examples 'simple crud for update with finder'
  include_examples 'simple crud for destroy with finder'
  include_examples 'simple crud for show'
  include_examples 'simple crud for update'
  include_examples 'simple crud for destroy'
end
