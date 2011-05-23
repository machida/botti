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
    if params[:tweet] && params[:tweet][:user_id]
      respond_to do |format|
        format.html { redirect_to user_path(params[:tweet][:user_id]),
          :notice=>notice, :alert => alert }
        format.js do
          render :json => {:alert => alert, :notice => notice,
            :messages => ""}, :content_type => 'text/json'
        end
      end
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
      redirect_to current_user, :notice => "声をかけました"
    rescue Twitter::Forbidden, Twitter::Unauthorized
      flash[:alert] = "投稿に失敗しました"
      render :template => "tweets/new_message"
      return
    end
  end
end
