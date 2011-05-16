desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  Tweet.remove_old_tweets
end
