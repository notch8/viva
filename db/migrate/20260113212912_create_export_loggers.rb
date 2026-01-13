class CreateExportLoggers < ActiveRecord::Migration[7.0]
  def change
    create_table :export_loggers do |t|
      t.timestamps
      t.string :export_type, null: false
      t.references :question, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
    end
  end
end
