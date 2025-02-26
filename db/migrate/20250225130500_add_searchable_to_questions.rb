class AddSearchableToQuestions < ActiveRecord::Migration[7.0]
  def up
    add_column :questions, :searchable, :tsvector
    add_index :questions, :searchable, using: 'gin'

    # Initialize the search vector for existing records
    Question.find_each(&:save)
  end

  def down
    remove_index :questions, :searchable
    remove_column :questions, :searchable
  end
end
