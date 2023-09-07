class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.text :text
      t.string :type, index: { unique: true }, null: false
      t.boolean :nested, default: false

      t.timestamps
    end
  end
end
