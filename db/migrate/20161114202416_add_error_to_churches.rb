class AddErrorToChurches < ActiveRecord::Migration
  def change
    add_column :churches, :error, :string
  end
end
