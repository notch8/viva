class AddUserToQuestions < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:questions, :user_id)
      add_reference :questions, :user, null: true, foreign_key: true
    end
  end
end
