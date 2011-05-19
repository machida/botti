module ApplicationHelper
  def config_twitter(auth)
    if auth
      Twitter.configure do |config|
        config.consumer_key = ENV['CONSUMER_KEY']
        config.consumer_secret = ENV['CONSUMER_SECRET']
        config.oauth_token = auth.token
        config.oauth_token_secret = auth.secret
      end
      return true
    else
      return false
    end
  end
end
