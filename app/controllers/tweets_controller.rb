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
      respond_with_alert("入力内容を確認してください。(位置情報は有効になっていますか?)")
      return
    end

    if params[:tweet][:ontwitter] == "1"
      begin
        config_twitter(current_user.authentications.find_by_provider("twitter"))
        Twitter.update(@tweet.content + ENV['TWITTER_SUFFIX'])
      rescue Twitter::Forbidden, Twitter::Unauthorized
        respond_with_alert notice + "Twitter への投稿に失敗しました。" +
          "正しいアカウントを登録していますか? おなじ内容の投稿をくりかえしていませんか?"
        return
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
        raise ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      respond_with_alert("その投稿はありません")
      return
    end
    respond_to do |format|
      format.html
      format.js { render :template => "tweets/_message_form",
        :layout => false, :content_type => 'text/html'}
    end
  end

  def create_message
    # user check
    begin
      @tweet = Tweet.find(params[:id])
      if !current_user.friends.include?(@tweet.user)
        raise ActiveRecord::RecordNotFound
      end
    rescue ActiveRecord::RecordNotFound
      respond_with_alert("その投稿はありません")
      return
    end

    # content check
    if params[:message].blank? || params[:message].jsize >= 100
      respond_with_alert("入力内容を確認してください。(入力されていますか?長すぎませんか?)", false)
      return
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
      respond_with_alert("投稿に失敗しました", false)
      return
    end

    respond_to do |format|
      notice = "声をかけました"
      format.html { redirect_to user_path, :notice => notice }
      format.js   { render :json => {:notice => notice },
        :content_type => "text/json" }
    end
  end
  private
  def respond_with_alert(alert, redirect = true)
    if alert
      respond_to do |format|
        format.html do
          flash[:alert] = alert
          if redirect
            redirect_to user_path, :alert => alert
          else
            render :action => "new_message"
          end
        end
        format.js   { render :json => {:alert => alert},
          :content_type => "text/json" }
      end
      return true
    else
      return false
    end
  end
end
