# frozen_string_literal: true

class AddClassroomSlugToDummyModels < ActiveRecord::Migration[6.0]
  def change
    add_column :dummy_models, :classroom_slug, :string
  end
end
