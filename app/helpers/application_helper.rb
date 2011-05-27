# -*- coding: utf-8 -*-
module ApplicationHelper
  def config_twitter(auth)
    if auth
      # this succeeds with any params (even if wrong)
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

Tweet.class_eval do
  include ActionView::Helpers::DateHelper
  def time
    time_ago_in_words(updated_at) + "前"
  end
end
