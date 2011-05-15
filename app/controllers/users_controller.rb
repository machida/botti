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
    @js_query = %Q%googlemap_controller.addFriend({
pos:new google.maps.LatLng(#{@user.tweets.first.location.lat},#{@user.tweets.first.location.lng}),
name: "#{@user.nickname || "ななしさん"}",
image_url: "#{@user.image_url || "/images/rails.png"}",
message: "#{@user.nickname}はここです"
});%
    render :template=>"users/map", :layout=>false
  end

  private
  def generate_js_string(tweet)
    user = tweet.user
    %Q% googlemap_controller.addFriend({
pos:new google.maps.LatLng(#{tweet.location.lat},#{tweet.location.lng}),
name: "#{user.nickname}",
image_url: "#{user.image_url || "/images/rails.png"}",
message: "#{user.nickname}はここです"
}
);%
  end
end
