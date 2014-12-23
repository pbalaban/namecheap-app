set :output, "#{path}/log/cron.log"

## 4AM EST == 9AM UTC
every 1.day, at: "9:00am" do
  rake 'cron:daily'
end
