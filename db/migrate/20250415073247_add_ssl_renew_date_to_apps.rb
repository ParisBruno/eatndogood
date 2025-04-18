class AddSslRenewDateToApps < ActiveRecord::Migration[5.2]
  def change
    add_column :apps, :ssl_renew_date, :date
  end
end
