class AllowNullQuestionInLogger < ActiveRecord::Migration[7.0]
  def change
    change_column_null :export_loggers, :question_id, true
  end
end
