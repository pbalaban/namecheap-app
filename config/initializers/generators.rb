Rails.application.config.generators do |g|
  g.test_framework     false
  g.view_specs         false
  g.helper_specs       false
  g.helper             false
  g.stylesheet_engine  :sass
end
