class AddFieldsToChurches < ActiveRecord::Migration
  def change
    add_column :churches, :main_email, :string
    add_column :churches, :processed_at, :datetime
  end
end
