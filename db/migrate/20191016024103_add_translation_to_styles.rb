class AddTranslationToStyles < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Style.create_translation_table!({
          :name => :string
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        Style.drop_translation_table! :migrate_data => true
      end
    end
  end
end
