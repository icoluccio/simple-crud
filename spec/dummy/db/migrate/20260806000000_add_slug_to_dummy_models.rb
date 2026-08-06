# frozen_string_literal: true

class AddSlugToDummyModels < ActiveRecord::Migration[6.0]
  def change
    add_column :dummy_models, :slug, :string
  end
end
