# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!, :only=>:show
  def show
    @user = User.find(params[:id])
    @tweets = @user.tweets.order("updated_at DESC")
    @tweet = Tweet.new(:user_id=>@user.id,
                   :content=>"ぼっち飯なう")
  end

  def create
    begin
      User.transaction do
        u2 = User.new(:email=>"puge")
        u2.save!
        u1 = User.new()
        u1.save!
      end
    rescue
      p "i got error message"
    end
    redirect_to root_path
  end
end
