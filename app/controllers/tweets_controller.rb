# -*- coding: utf-8 -*-
require 'jcode' # length validation
class TweetsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = Tweet.new(params[:tweet])
    begin
      @tweet.set_location
      @tweet.save!
      flash[:notice] = "投稿しました。"
    rescue Geokit::Geocoders::GeocodeError, ActiveRecord::RecordInvalid
      flash[:alert] = "入力内容を確認してください。(位置情報は有効になっていますか?)"
    end

    if params[:tweet][:ontwitter] == "1"
      begin
        config_twitter
        Twitter.update(@tweet.content + ENV['TWITTER_SUFFIX'])
      rescue Twitter::Forbidden, Twitter::Unauthorized
        flash[:alert] = "Twitter への投稿に失敗しました。正しいアカウントを登録していますか? おなじ内容の投稿をくりかえしていませんか?"
      end
    end
    if params[:tweet] && params[:tweet][:user_id]
      redirect_to user_path(params[:tweet][:user_id])
    else
      flash[:alert] = "不正な投稿"
      redirect_to root_path
    end
  end

  def new_message
    @tweet = Tweet.find(params[:id])
    # user check
    if @tweet.user == current_user
      redirect_to current_user, :notice => "自分は誘えません"
      return
    end
    # create string
  end

  def create_message
    @tweet = Tweet.find(params[:id])
    # user check
    if @tweet.user == current_user
      redirect_to current_user, :notice => "自分は誘えません"
      return
    end
    # content check
    if params[:message].blank? || params[:message].jsize >= 100
      flash[:alert] = "入力内容を確認してください。(入力されていますか?長すぎませんか?)"
      render :template => "tweets/new_message"
      return
    end
    # send DM
    begin
      config_twitter()
      Twitter.direct_message_create(@tweet.user.authentications.first.uid,
                             params[:message] + ENV['MESSAGE_SUFFIX'])
      redirect_to current_user, :notice => "声をかけました"
    rescue Twitter::Forbidden, Twitter::Unauthorized
      flash[:alert] = "投稿に失敗しました"
      render :template => "tweets/new_message"
      return
    end
  end

  private
  def config_twitter
    if auth = current_user.authentications.find_by_provider("twitter")
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
