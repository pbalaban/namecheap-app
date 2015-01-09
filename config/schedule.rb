set :output, "#{path}/log/cron.log"

## 6AM EST == 11AM UTC == 3AM PST == 1PM Kiev
every 1.day, at: "06:00am" do
  rake 'cron:daily'
end
