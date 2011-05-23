# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!
  def show
    @js_query = ""
    @tweets = current_user.tweets.order("updated_at DESC")
    @tweet = Tweet.new( :user_id => current_user.id, :content => "ぼっち飯なう" )
    # @friend_tweets = get_friend_tweets(@user)
    # if @user.tweets.count > 0
    #   @friend_tweets << @user.tweets.order("updated_at DESC").first
    # end
    # @friend_tweets.reverse.each do |t|
    #   @js_query += generate_json(t.user, t)
    # end
  end

  def friend_tweets
    @ft = []

    current_user.friends.each do |f|
      if f.tweets.count > 0
        @ft << f.tweets.order("updated_at DESC").first
      end
    end
    @ft.sort_by{|obj| obj.updated_at}

    if current_user.tweets.count > 0
      @friend_tweets << current_user.tweets.order("updated_at DESC").first
    end

    respond_to do |format|
      format.js   { render :json => @ft, :content_type => "text/json" }
    end
  end

  private
  def generate_json(user, tweet)
    unless tweet.location
      p tweet
      return
    end
    params = {
      :address => tweet.location.address,
      :lat => tweet.location.lat,
      :lng => tweet.location.lng,
      :name => user.nickname,
      :image_url => user.image_url,
      :content => tweet.content,
      :link => (user == current_user) ? "" : "<a href=#{message_tweet_path(tweet)}>DM</a>",
      :time => tweet.time
    }
    %Q% googlemap_controller.addFriend(#{params.to_json});%
  end

end
