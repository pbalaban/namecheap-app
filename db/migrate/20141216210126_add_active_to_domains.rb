class AddActiveToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :active, :boolean, default: false, null: false
  end
end
