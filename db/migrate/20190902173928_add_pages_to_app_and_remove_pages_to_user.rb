class AddPagesToAppAndRemovePagesToUser < ActiveRecord::Migration[5.1]
  def change
    add_reference :pages, :app, foreign_key: true
    remove_reference :pages, :user
  end
end
