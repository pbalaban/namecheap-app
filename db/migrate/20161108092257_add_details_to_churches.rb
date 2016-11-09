class AddDetailsToChurches < ActiveRecord::Migration
  def change
    add_column :churches, :details, :jsonb, null: false, default: '{}'
  end
end
