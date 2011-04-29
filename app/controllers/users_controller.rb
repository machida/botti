# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!
  def show
    @user = User.find(params[:id])
    @tweets = @user.tweets.order("updated_at DESC")
    @tweet = Tweet.new(:user_id=>@user.id,
                       :content=>"ぼっち飯なう")
  end

end
