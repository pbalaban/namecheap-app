class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.string :tld
      t.string :listing_url
      t.decimal :price, precision: 8, scale: 2
      t.datetime :closing_on
      t.datetime :listed_on
      t.datetime :expires_on

      t.timestamps
    end
  end
end
