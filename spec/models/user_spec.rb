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
      @url = "http://example.com/pseudo.png"
      @oa_sample = {
        'uid' => '123456',
        'user_info' => {
          'name'=>'Botti Testkun',
          'nickname'=>'bottitester',
          'description' => 'This is TestAccount',
          'image' => @url
        },
        'credentials' => {
          'token' => ENV['USER_TOKEN'],
          'secret' => ENV['USER_SECRET']
        },
        'provider' => 'twitter'
      }
    end

    context "when image is refreshed" do
      before do
        @u = User.make
        @u.image_url.should_not == @url # gauntlet
        @u.update_info(@oa_sample)
      end
      subject{@u}
      its(:image_url) { should == @url }
    end

    describe "loading friend" do
      before do
        @a = Authentication.make(:uid=>287606751, :provider=>"twitter")
        @tomykaira = User.make(:authentications=>[@a])
        @botti = User.make
        @botti.update_info(@oa_sample)
      end

      it "should add @tomykaira to friends" do
        @botti.friends.first.should == @tomykaira
      end
    end
  end
end
