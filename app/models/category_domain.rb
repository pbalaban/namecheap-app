class CategoryDomain < ActiveRecord::Base
  ## Associations
  belongs_to :category
  belongs_to :domain
end
