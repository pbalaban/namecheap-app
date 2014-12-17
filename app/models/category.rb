class Category < ActiveRecord::Base
  ## Associations
  has_many :category_domains, dependent: :destroy
  has_many :domains, through: :category_domains
end
