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
end
