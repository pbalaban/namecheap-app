class CreateCategoryDomains < ActiveRecord::Migration
  def change
    create_table :category_domains do |t|
      t.references :category, index: true
      t.references :domain, index: true

      t.timestamps
    end

    add_index :category_domains, [:category_id, :domain_id], unique: true
  end
end
