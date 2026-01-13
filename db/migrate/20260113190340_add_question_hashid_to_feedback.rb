class AddQuestionHashidToFeedback < ActiveRecord::Migration[7.0]
  def change
    add_column :feedbacks, :question_hashid, :string
  end
end
