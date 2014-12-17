require 'open-uri'

namespace :import do
  desc 'Initial import categories from site'
  task categories: :environment do
    Category.destroy_all
    ImportCategories.perform
  end
end
