class AddFullTextSearchToQuestions < ActiveRecord::Migration[7.0]
  def change
    # Add a tsvector column that stores full-text search data
    add_column :questions, :tsv, :tsvector

    # Create a GIN index for fast full-text search
    add_index :questions, :tsv, using: :gin

    # Create a trigger to automatically update `tsv` on insert/update
    execute <<-SQL
      CREATE FUNCTION questions_tsvector_update() RETURNS trigger AS $$
      BEGIN
        NEW.tsv := 
          setweight(to_tsvector('english', coalesce(NEW.text, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(NEW.data::text, '')), 'B');
        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER questions_tsvector_trigger
      BEFORE INSERT OR UPDATE ON questions
      FOR EACH ROW EXECUTE FUNCTION questions_tsvector_update();
    SQL
  end
end
