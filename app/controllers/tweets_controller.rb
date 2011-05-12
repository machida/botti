# -*- coding: utf-8 -*-
class TweetsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = Tweet.new(params[:tweet])
    @tweet.set_location

    if @tweet.save
      auth = current_user.authentications.find_by_provider("twitter")
      if auth
        Twitter.configure do |config|
          config.consumer_key = ENV['CONSUMER_KEY']
          config.consumer_secret = ENV['CONSUMER_SECRET']
          ## get when user activates
          config.oauth_token = auth.token
          config.oauth_token_secret = auth.secret
        end
        Twitter.update(@tweet.content)
        temp_notice = "twitter に投稿しました。"
      else
        temp_notice = "関連づけられた twitter アカウントが見つかりませんでした。"
      end
      redirect_to user_path(params[:tweet][:user_id]), :notice => "投稿成功" + temp_notice
    else
      render :action => 'new'
    end
  end
end
