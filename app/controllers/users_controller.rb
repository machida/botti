# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!
  def show
    @user = User.find(params[:id])
    if @user != current_user
      redirect_to current_user
    end
    @tweets = @user.tweets.order("updated_at DESC")
    @tweet = Tweet.new(:user_id=>@user.id,
                   :content=>"ぼっち飯なう")
    @friend_tweets = get_friend_tweets(@user)
    if @user.tweets.count > 0
      @friend_tweets << @user.tweets.order("updated_at DESC").first
    end
    @friend_tweets.reverse.each do |t|
      @js_query = generate_json(t.user, t)
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

  def get_friend_tweets(user)
    ft = []
    user.friends.each do |f|
      if f.tweets.count > 0
        ft << f.tweets.order("updated_at DESC").first
      end
    end
    ft.sort_by{|obj| obj.updated_at}
  end
end
