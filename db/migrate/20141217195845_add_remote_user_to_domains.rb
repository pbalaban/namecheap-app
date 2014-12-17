class AddRemoteUserToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :remote_user, :string
  end
end
