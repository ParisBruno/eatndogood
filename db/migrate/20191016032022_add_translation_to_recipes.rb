class AddTranslationToRecipes < ActiveRecord::Migration[5.2]
  def change
    # reversible do |dir|
    #   dir.up do
    #     Recipe.create_translation_table!({
    #       :name => :string,
    #       :description => :text,
    #       :summary => :text
    #     }, {
    #       :migrate_data => true
    #     })
    #   end

    #   dir.down do
    #     Recipe.drop_translation_table! :migrate_data => true
    #   end
    # end
  end
end
