# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!, :only=>:show
  def show
    @user = User.find(params[:id])
    @tweets = @user.tweets.order("updated_at DESC")
    @tweet = Tweet.new(:user_id=>@user.id,
                   :content=>"ぼっち飯なう")
  end

  def map
    @user = User.find(params[:id])
    if @user.tweets.first
      @js_query = generate_js_string(@user.tweets.first)
    end
    render :template=>"users/map", :layout=>false
  end

  private
  def generate_js_string(tweet)
    user = tweet.user
    %Q% googlemap_controller.addFriend({
pos:new google.maps.LatLng(#{tweet.location.lat},#{tweet.location.lng}),
name: "#{user.nickname}",
image_url: "#{user.image_url || "/images/rails.png"}",
message: "#{user.nickname}: #{tweet.content} (#{tweet.updated_at.strftime("%H:%M %d日")})"
}
);%
  end
end
