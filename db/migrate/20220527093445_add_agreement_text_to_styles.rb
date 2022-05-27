class AddAgreementTextToStyles < ActiveRecord::Migration[5.2]
  def change
    add_column :styles, :agreement_text, :text
  end
end
