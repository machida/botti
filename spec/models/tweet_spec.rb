# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Tweet do
  describe "set location" do
    context "with the position" do
      before do
        @t = Tweet.new(:content=>"Sample Tweet", :user_id=>1, :ll=>"35.647401,139.716911")
        @t.set_location
      end

      subject {@t}
      it { should be_valid }
      its("ll") { should == "35.647401,139.716911" }
      its("location.lat") { should == 35.647401 }
      its("location.lng") { should == 139.716911 }
      its("location.address") { should be_include "渋谷" }
    end
    context "without ll" do
      before do
        @t = Tweet.new(:content=>"Sample Tweet", :user_id=>1, :ll=>"")
      end

      it { lambda { @t.set_location }.should raise_error }
    end
  end

  describe "remove old tweets" do
    before do
      Tweet.any_instance.stubs(:valid?).returns(true)
      Tweet.class_eval { attr_accessible :updated_at }
      Tweet.create!(:updated_at=>4.days.ago)
      Tweet.create!(:updated_at=>2.days.ago)
      Tweet.create!(:updated_at=>1.days.ago)
      Tweet.all.count.should == 3 #gauntlet
      Tweet.remove_old_tweets
    end
    it { Tweet.all.count.should == 2 }
  end

  describe "reply" do
    before do
      # @u = mock_model(User,
      #           :nickname => "Test_Name",
      #           :authentications => mock_model("PseudoArray", :find_by_provider => mock_model(Authentication, :uid => 123456, :token=> "tekitou", :secret => "tekitou"))
      #           )
      @u = User.make
      @t = Tweet.make
    end
    context "when update fails" do
      before do
        Twitter.stub(:direct_message_create).and_return true
        Twitter.stub(:update).and_raise(Twitter::Unauthorized)
      end
      it { @t.reply(@u, "Mention", "message").should == false }
      it { @t.reply(@u, "DM", "message").should == true }
    end

    context "when DM fails" do
      before do
        Twitter.stub(:update).and_return true
        Twitter.stub(:direct_message_create).and_raise(Twitter::Unauthorized)
      end
      it { @t.reply(@u, "Mention", "message").should == true }
      it { @t.reply(@u, "DM", "message").should == false }
    end
  end
end
