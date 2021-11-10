class AddSelectedLanguagesToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :selected_languages, :text, array: true, default: ['en_primary']
  end
end
