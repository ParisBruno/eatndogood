class AddTranslationToPagePreviews < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        PagePreview.create_translation_table!({
          :title => :string,
          :content => :text
        }, {
          :migrate_data => true
        })
      end

      dir.down do
        PagePreview.drop_translation_table! :migrate_data => true
      end
    end
  end
end
