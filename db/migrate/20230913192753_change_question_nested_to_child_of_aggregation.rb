class ChangeQuestionNestedToChildOfAggregation < ActiveRecord::Migration[7.0]
  def change
    rename_column :questions, :nested, :child_of_aggregation
  end
end
