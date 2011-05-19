# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do
  context "when a friend is added" do
    before do
      @u = User.make
      @u.friends << (@new = User.make)
      @u.save!
    end
    it { @u.friends.first.should == @new }
    it { @u.friends.count.should == 1 }
  end

  describe "update_info" do
    before do
      @oa_sample = TEST_OAINFO
    end

    context "when image is refreshed" do
      before do
        @u = User.make
        @u.image_url.should_not == TEST_OAINFO['user_info']['image'] # gauntlet
        Twitter.stub(:friend_ids).and_return({"ids"=>[]})
        @u.update_info(@oa_sample)
      end
      subject{@u}
      its(:nickname) { should == TEST_OAINFO['user_info']['nickname'] }
      its(:image_url) { should == TEST_OAINFO['user_info']['image'] }
    end

    describe "loading friend" do
      before do
        @tomykaira = User.make(:authentications=>[
                                 Authentication.make(:uid=>123456)])
        @botti = User.make()
        Twitter.stub(:friend_ids).and_return({"ids" => [123456]})
        @botti.update_info(@oa_sample)
      end

      it "should add @tomykaira to friends" do
        @botti.friends.first.should == @tomykaira
      end

      it { @botti.connections.count.should == 1 }

      context "when I login twice" do
        before { @botti.update_info(@oa_sample) }
        it { @botti.connections.count.should == 1}
      end
    end
  end
end
