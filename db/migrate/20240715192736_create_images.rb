class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :alt_text
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
