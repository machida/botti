# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @tweet = Tweet.new( :user_id => current_user.id, :content => "ぼっち飯なう" )
  end

  def friend_tweets
    @ft = []

    current_user.friends.each do |f|
      if f.tweets.count > 0
        t = f.tweets.order("updated_at DESC").first
        t.myself = false
        @ft << t
      end
    end
    @ft.sort_by{|obj| obj.updated_at}

    # include myself
    if current_user.tweets.count > 0
      t = current_user.tweets.order("updated_at DESC").first
      t.myself = true
      @ft << t
    end

    respond_to do |format|
      ActiveRecord::Base.include_root_in_json = false
      format.js   { render :json => @ft, :content_type => "text/json" }
    end
  end
end
