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
        post :create
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
    end
  end

  context "when a user who does not use twitter post" do
  end

  context "when a twitter post" do
    before do
      @u.authentications.build(:provider=>"twitter",
                       :uid=>123456,
                       :token=>ENV['USER_TOKEN'],
                       :secret=>ENV['USER_SECRET'])
      @u.save!
      User.find(@u.id).authentications.find_by_provider("twitter").
        should_not be_nil ##gautlet
      Tweet.count.should == 0 #gauntlet
      Tweet.any_instance.stubs(:valid?).returns(true)
    end

    context "when the post is accepted by Twitter" do
      before do
        Twitter.should_receive(:update).and_return(true)
        post :create, :tweet=>{:user_id=>@u.id}
      end
      it { Tweet.count.should == 1 }
      it { flash[:notice].should == "twitter に投稿しました。" }
      it { flash[:warning].should be_nil }
      it { response.should redirect_to @u }
    end

    context "when the post is not accepted" do
      before do
        Tweet.count.should == 0 #gauntlet
        Twitter.should_receive(:update).and_raise(Twitter::Forbidden)
        post :create, :tweet=>{:user_id=>@u.id}
      end
      it { Tweet.count.should == 0 }
      it { p Tweet.first }
      it { flash[:notice].should be_nil }
      it { flash[:warning].should contain "おなじ内容の投稿を繰替えしていませんか?"}
      it { response.should redirect_to @u }
    end
  end
end
