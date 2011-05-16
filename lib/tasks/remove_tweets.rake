reqiure 'tweet.rb'
task :cron do
  Tweet.remove_old_tweets
end
