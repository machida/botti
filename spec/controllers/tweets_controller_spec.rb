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
      post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"1",
        :content => "pseudo content"}
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

  describe "new message" do
    context "when the target is me" do
      before do
        Tweet.stub(:find).with("49"){ mock_tweet(:user => @u) }
        get :new_message, :id => "49"
      end
      it { response.should redirect_to @u }
      it { flash[:notice].should == "自分は誘えません"}
    end
  end

  describe "create message" do
    before do
      Twitter.stub(:direct_message_create).and_return true
      Tweet.stub(:find).with("49"){
        mock_tweet(:user => User.make, :content => "dummy")
      }
      @string = "あいうえおあいうえお" #10
    end

    context "when the target is me" do
      before do
        Tweet.stub(:find).with("37"){ mock_tweet(:user => @u) }
        post :create_message, :id => "37"
      end
      it { response.should redirect_to @u }
      it { flash[:notice].should == "自分は誘えません"}
    end

    context "when the message is a little bit long" do
      before do
        post :create_message, :id => "49", :message=> @string * 6
      end
      it { response.should redirect_to @u }
      it { flash[:notice].should == "声をかけました"}
    end

    context "when the message is too long" do
      before do
        post :create_message, :id => "49", :message=> @string * 11
      end
      it { response.should render_template "tweets/new_message" }
      it { flash[:alert].should be_include "確認してください"}
    end

    context "when the message is empty" do
      before do
        post :create_message, :id => "49", :message => " "
      end
      it { response.should render_template "tweets/new_message" }
      it { flash[:alert].should be_include "確認してください"}
    end
  end
end
