class AddTranslationToChefs < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Chef.create_translation_table!({
          :my_bio => :text
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        Chef.drop_translation_table! :migrate_data => true
      end
    end
  end
end
