class AddEmailsToChurches < ActiveRecord::Migration
  def change
    add_column :churches, :emails, :text
  end
end
