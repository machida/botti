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
      its("location.address") { should be_include "Shibuya" }
    end
    context "without ll" do
      before do
        @t = Tweet.new(:content=>"Sample Tweet", :user_id=>1, :ll=>"")
        @t.set_location
      end

      subject {@t}
      it { should be_valid }
    end
  end
end
