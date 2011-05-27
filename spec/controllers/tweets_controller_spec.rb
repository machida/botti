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

  describe "POST create" do
    context "when the post is invalid" do
      context "when the model is invalid" do
        before do
          Tweet.stub(:new).with({"user_id" => @u.id}){ mock_tweet }
          mock_tweet.stub!(:set_location).and_return true
          mock_tweet.stub!(:save!).and_raise(ActiveRecord::RecordInvalid.new(mock_tweet))
          post :create, :tweet=>{:user_id => @u.id}
        end
        it { response.should redirect_to user_path}
        it { flash[:alert].should contain "入力内容を確認してください。" }
      end

      context "when the set_location fails" do
        before do
          Tweet.stub(:new).with({"user_id" => @u.id}){ mock_tweet() }
          mock_tweet.stub(:set_location).and_raise(Geokit::Geocoders::GeocodeError)
          post :create, :tweet=>{:user_id =>@u.id}
        end
        it { response.should redirect_to user_path}
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
        Tweet.stub(:new){
          mock_tweet(:save! => true,
               :set_location => true,
               :content => "pseudo content",
               :user_id=>@u.id)
        }
        Twitter.should_receive(:update).and_raise(Twitter::Forbidden)
        post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"1",
          :content => "pseudo content"}
      end
      it { flash[:alert].should contain "投稿しました。" }
      it { flash[:alert].should contain "おなじ内容の投稿をくりかえしていませんか?"}
      it { response.should redirect_to user_path }
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
        Tweet.stub(:new){
          mock_tweet(:save! => true,
               :set_location => true,
               :user_id=>@u.id)
        }
        post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"0"}
      end
      it { flash[:notice].should == "投稿しました。" }
      it { flash[:alert].should be_nil}
      it { response.should redirect_to user_path }
    end
  end

  describe "new message" do
    context "when the target is me" do
      before do
        Tweet.stub(:find).with("49"){ mock_tweet(:user => @u) }
        get :new_message, :id => "49"
      end
      it { response.should redirect_to user_path }
      it { flash[:alert].should == "その投稿はありません"}
    end
  end

  describe "create message" do
    context "when the target is me" do
      before do
        Tweet.stub(:find).with("37"){ mock_tweet(:user => @u) }
        post :create_message, :id => "37"
      end
      it { response.should redirect_to user_path }
      it { flash[:alert].should == "その投稿はありません"}
    end

    context "when the target is another friend" do
      before do
        @owner = User.make()
        mock_tweet(:user => @owner, :content => "dummy")
        Tweet.stub(:find).with("49"){ mock_tweet }
        @u.friends << @owner
        @u.save!
        @string = "あいうえおあいうえお" #10
      end

      context "when the message is a little bit long" do
        before do
          mock_tweet.should_receive(:reply).and_return(true)
          post :create_message, :id => "49", :message=> @string * 6
        end
        it { response.should redirect_to user_path }
        it { flash[:notice].should == "声をかけました"}
      end

      context "when the authentication failed on posting" do
        before do
          mock_tweet.should_receive(:reply).and_return(false)
          post :create_message, :id => "49", :message=> @string * 6
        end
        it { response.should redirect_to user_path }
        it { flash[:alert].should == "投稿に失敗しました"}
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
end
