# frozen_string_literal: true

class CreateStructuredErrors < ActiveRecord::Migration[4.2]
  def change
    create_table :structured_errors do |t|
      t.references :error_template
      t.belongs_to :file

      t.timestamps null: false
    end
  end
end
