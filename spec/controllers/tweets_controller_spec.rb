# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe TweetsController do
  render_views
  before do
    @u = login_user
  end

  def mock_tweet(stubs={})
    @mock_tweet ||= mock_model(Tweet, stubs)
  end

  context "when the post is invalid" do
    context "when the query is send not from a form" do
      before do
        Tweet.stub(:new).with({"ontwitter" => '0'}){
          mock_model(Tweet, {:save! => true, :set_location => true})
        }
        post :create, :tweet=>{:ontwitter => '0'}
      end
      it { response.should redirect_to root_path }
      it { flash[:alert].should contain "不正な投稿" }
    end

    context "when the model is invalid" do
      before do
        Tweet.stub(:new).with({"user_id" => @u.id}){
          mock_tweet(:user_id => @u.id) }
        mock_tweet.stub!(:set_location).and_return true
        mock_tweet.stub!(:save!).and_raise(ActiveRecord::RecordInvalid.new(mock_tweet))
        post :create, :tweet=>{:user_id => @u.id}
      end
      it { response.should redirect_to @u}
      it { flash[:alert].should contain "入力内容を確認してください。" }
      after do
        Tweet.any_instance.stubs(:valid?).returns(true)
      end
    end

    context "when the set_location fails" do
      before do
        Tweet.stub(:new).with({"user_id" => @u.id}){
          mock_tweet(:save=> true) }
        mock_tweet.stub(:set_location).and_raise(Geokit::Geocoders::GeocodeError)
        post :create, :tweet=>{:user_id =>@u.id}
      end
      it { response.should redirect_to @u}
      it { flash[:alert].should contain "入力内容を確認してください。" }
    end
  end

  context "when the post is not accepted by Twitter" do
    before do
      @u.authentications.build(:provider=>"twitter",
                       :uid=>'123456',
                       :token=>ENV['USER_TOKEN'],
                       :secret=>ENV['USER_SECRET'])
      @u.save!
      User.find(@u.id).authentications.find_by_provider("twitter").
        should_not be_nil ##gautlet
      Tweet.any_instance.stubs(:set_location).returns(true)
      Twitter.should_receive(:update).and_raise(Twitter::Forbidden)
      post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"1"}
    end
    it { flash[:notice].should contain "投稿しました。" }
    it { flash[:alert].should contain "おなじ内容の投稿をくりかえしていませんか?"}
    it { response.should redirect_to @u }
  end

  context "when not tweeting on twitter" do
    before do
      @u.authentications.build(:provider=>"twitter",
                       :uid=>'123456',
                       :token=>ENV['USER_TOKEN'],
                       :secret=>ENV['USER_SECRET'])
      @u.save!
      User.find(@u.id).authentications.find_by_provider("twitter").
        should_not be_nil ##gautlet
      Tweet.any_instance.stubs(:set_location).returns(true)
      post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"0"}
    end
    it { flash[:notice].should contain "投稿しました。" }
    it { flash[:alert].should be_nil}
    it { response.should redirect_to @u }
  end
end
