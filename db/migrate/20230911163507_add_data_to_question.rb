class AddDataToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :data, :text, default: nil
  end
end
