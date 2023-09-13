class CreateQuestionAggregations < ActiveRecord::Migration[7.0]
  def change
    create_table :question_aggregations do |t|
      t.integer :parent_question_id, null: false, foreign_key: true
      t.string :parent_question_type, null: false
      t.integer :child_question_id, null: false, foreign_key: true
      t.string :child_question_type, null: false
      t.integer :presentation_order, null: false, index: true

      t.timestamps
    end

    add_index :question_aggregations, [:parent_question_id, :child_question_id, :presentation_order], unique: true, name: :question_aggregations_parent_child_idx
  end
end
