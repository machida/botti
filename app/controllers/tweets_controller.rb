# -*- coding: utf-8 -*-
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
      auth = current_user.authentications.find_by_provider("twitter")
      if auth
        Twitter.configure do |config|
          config.consumer_key = ENV['CONSUMER_KEY']
          config.consumer_secret = ENV['CONSUMER_SECRET']
          config.oauth_token = auth.token
          config.oauth_token_secret = auth.secret
          if ENV['APIGEE_TWITTER_API_ENDPOINT']
            p config.api_endpoint = "http://" + ENV['APIGEE_TWITTER_API_ENDPOINT']
          end
        end

        begin
          Twitter.update(@tweet.content)
        rescue Twitter::Forbidden
          flash[:alert] = "投稿に失敗しました。次を確認してください。正しいアカウントを登録していますか? おなじ内容の投稿をくりかえしていませんか?"
        end
      else
        flash[:alert] = "関連づけられた twitter アカウントが見つかりませんでした。"
      end
    end
    if params[:tweet] && params[:tweet][:user_id]
      redirect_to user_path(params[:tweet][:user_id])
    else
      flash[:alert] = "不正な投稿"
      redirect_to root_path
    end
  end
end
