class CreateJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :questions, :keywords do |t|
      # We really only want one pairing of a question and a keyword.  Hence the uniqueness constraint.
      t.index [:question_id, :keyword_id], unique: true
      t.index [:keyword_id, :question_id]
    end

    create_join_table :questions, :categories do |t|
      # We really only want one pairing of a question and a category.  Hence the uniqueness constraint.
      t.index [:question_id, :category_id], unique: true
      t.index [:category_id, :question_id]
    end
  end
end
