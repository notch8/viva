class CreateJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :questions, :keywords do |t|
      t.index [:question_id, :keyword_id]
      t.index [:keyword_id, :question_id]
    end

    create_join_table :questions, :categories do |t|
      t.index [:question_id, :category_id]
      t.index [:category_id, :question_id]
    end
  end
end
