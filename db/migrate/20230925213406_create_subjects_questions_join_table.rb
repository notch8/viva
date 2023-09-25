class CreateQuestionsSubjectsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :subjects, :questions do |t|
      # We really only want one pairing of a question and a subject.  Hence the uniqueness constraint.
      t.index [:question_id, :subject_id], unique: true
      t.index [:subject_id, :question_id]
    end
  end
end
