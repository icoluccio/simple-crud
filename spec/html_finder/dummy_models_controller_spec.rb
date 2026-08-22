# frozen_string_literal: true

require 'spec_helper'

describe HtmlFinder::DummyModelsController, type: :controller do
  include_examples 'simple crud for edit'
  include_examples 'simple crud for show with finder'
  include_examples 'simple crud for update with finder'
  include_examples 'simple crud for destroy with finder'
  include_examples 'simple crud for new with build'
end
