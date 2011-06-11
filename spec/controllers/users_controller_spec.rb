require 'spec_helper'

describe UsersController do
  before { @u = login_user }

  describe "GET 'show'" do
    it "should be successful" do
      get 'show', :id=>@u.id
      response.should be_success
    end
  end

  describe "GET 'friend_tweets'" do
    before do
      @my_tweet = Tweet.make(:myself => true, :user => @u)
      @friend_tweet = Tweet.make(:myself => false)
      @u.friends << @friend_tweet.user
      get "friend_tweets"
    end
    it { p response }
  end
end
