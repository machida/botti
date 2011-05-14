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
      flash[:notice] = "投稿しました。"
    else
      flash[:warning] = "入力内容を確認してください。"
    end

    if params[:tweet][:ontwitter] == "1"
      auth = current_user.authentications.find_by_provider("twitter")
      if auth
        Twitter.configure do |config|
          config.consumer_key = ENV['CONSUMER_KEY']
          config.consumer_secret = ENV['CONSUMER_SECRET']
          config.oauth_token = auth.token
          config.oauth_token_secret = auth.secret
        end

        begin
          Twitter.update(@tweet.content)
        rescue Twitter::Forbidden
          flash[:warning] = "投稿に失敗しました。次を確認してください。正しいアカウントを登録していますか? おなじ内容の投稿をくりかえしていませんか?"
        end
      else
        flash[:warning] = "関連づけられた twitter アカウントが見つかりませんでした。"
      end
    end
      if params[:tweet] && params[:tweet][:user_id]
        redirect_to user_path(params[:tweet][:user_id])
      else
        flash[:warning] = "不正な投稿"
        redirect_to root_path
      end
  end
end
