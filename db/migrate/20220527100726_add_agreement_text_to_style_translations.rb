class AddAgreementTextToStyleTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :style_translations, :agreement_text, :text
  end
end
