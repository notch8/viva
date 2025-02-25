class RemoveKeywords < ActiveRecord::Migration[7.0]
  def up
    drop_table :keywords_questions
    drop_table :keywords
  end

  def down
    create_table :keywords do |t|
      t.string :name, null: false
      t.timestamps
      t.index :name, unique: true
    end

    create_join_table :questions, :keywords do |t|
      t.index [:question_id, :keyword_id], unique: true
      t.index [:keyword_id, :question_id]
    end
  end
end
