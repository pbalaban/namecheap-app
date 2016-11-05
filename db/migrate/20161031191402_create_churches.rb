class CreateChurches < ActiveRecord::Migration
  def change
    create_table :churches do |t|
      t.integer :remote_id
      t.string  :title
      t.string  :breadcrumb
      t.text    :html

      t.timestamps
    end
  end
end
