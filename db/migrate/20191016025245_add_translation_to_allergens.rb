class AddTranslationToAllergens < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Allergen.create_translation_table!({
          :name => :string
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        Allergen.drop_translation_table! :migrate_data => true
      end
    end
  end
end
