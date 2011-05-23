# -*- coding: utf-8 -*-
require 'jcode' # length validation
class TweetsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  def new
    @tweet = Tweet.new
  end

  def create
    @tweet = Tweet.new(params[:tweet])
    begin
      @tweet.set_location
      @tweet.save!
      notice = "投稿しました。"
    rescue Geokit::Geocoders::GeocodeError, ActiveRecord::RecordInvalid
      alert = "入力内容を確認してください。(位置情報は有効になっていますか?)"
    end

    if params[:tweet][:ontwitter] == "1"
      begin
        config_twitter(current_user.authentications.find_by_provider("twitter"))
        Twitter.update(@tweet.content + ENV['TWITTER_SUFFIX'])
      rescue Twitter::Forbidden, Twitter::Unauthorized
        alert = "Twitter への投稿に失敗しました。" +
          "正しいアカウントを登録していますか? おなじ内容の投稿をくりかえしていませんか?"
      end
    end
    respond_to do |format|
      format.html { redirect_to user_path, :notice => notice, :alert => alert }
      format.js do
        render :json => {:alert => alert, :notice => notice,
          :messages => ""}, :content_type => 'text/json'
      end
    end
  end

  def new_message
    # user check
    begin
      @tweet = Tweet.find(params[:id])
      if !current_user.friends.include?(@tweet.user)
        ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      alert = "その投稿はありません"
    end
    respond_to do |format|
      if alert
        format.html { redirect_to user_path, :alert => alert }
        format.js   { render :json => { :alert => alert },
          :content_type => 'text/json' }
      else
        format.html
        format.js { render :template => "tweets/_message_form",
          :layout => false, :content_type => 'text/html'}
      end
    end
  end

  def create_message
    @tweet = Tweet.find(params[:id])

    # user check
    if @tweet.user == current_user
      alert = "自分は誘えません"
    end

    # content check
    if params[:message].blank? || params[:message].jsize >= 100
      alert = "入力内容を確認してください。(入力されていますか?長すぎませんか?)"
    end

    # send DM / Mention
    begin
      config_twitter(current_user.authentications.find_by_provider("twitter"))
      if params[:method] == "Mention"
        Twitter.update("@" + @tweet.user.nickname + " " +
                params[:message] + ENV['TWITTER_SUFFIX'])
      else
        Twitter.direct_message_create(@tweet.user.authentications.first.uid,
                               params[:message] + ENV['MESSAGE_SUFFIX'])
      end
    rescue Twitter::Forbidden, Twitter::Unauthorized
      alert = "投稿に失敗しました"
    end

    respond_to do |format|
      if alert
        format.html { render :template => "tweets/new_message" }
        format.js   { render :json => {:alert => alert},
          :content_type => "text/json" }
      else
        notice = "声をかけました"
        format.html { redirect_to user_path, :notice => notice }
        format.js   { render :json => {:notice => notice },
          :content_type => "text/json" }
      end
    end
  end
end
