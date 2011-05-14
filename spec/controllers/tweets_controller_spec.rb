# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe TweetsController do
  render_views
  before do
    @u = login_user
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  context "when the post is invalid" do
    context "when the query is send not from a form" do
      before do
        post :create, :tweet=>{:ontwitter => "0"}
      end
      it { response.should redirect_to root_path }
      it { flash[:warning] == "不正な投稿" }
    end

    context "when the model is invalid" do
      before do
        Tweet.any_instance.stubs(:valid?).returns(false)
        post :create, :tweet=>{:user_id => @u.id}
      end
      it { response.should redirect_to @u}
      it { flash[:warning] == "入力内容を確認してください。" }
      after do
        Tweet.any_instance.stubs(:valid?).returns(true)
      end
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
      Twitter.should_receive(:update).and_raise(Twitter::Forbidden)
      post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"1"}
    end
    it { flash[:notice].should contain "投稿しました。" }
    it { flash[:warning].should contain "おなじ内容の投稿をくりかえしていませんか?"}
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
      post :create, :tweet=>{:user_id=>@u.id, :ontwitter=>"0"}
    end
    it { flash[:notice].should contain "投稿しました。" }
    it { flash[:warning].should be_nil}
    it { response.should redirect_to @u }
  end
end
