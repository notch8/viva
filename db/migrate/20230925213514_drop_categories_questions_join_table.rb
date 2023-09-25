class DropCategoriesQuestionsJoinTable < ActiveRecord::Migration[7.0]
  def change
    drop_join_table :categories, :questions
  end
end
