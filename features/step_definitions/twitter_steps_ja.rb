# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

@last_post_text = ""

前提 /^twitter アカウントを登録している/ do
  前提 %{twitter ログイン}
  前提 %{ログアウト}
end

前提 /^twitter ログイン準備$/ do
  OmniAuth.config.mock_auth[:twitter] = TEST_OAINFO
end

前提 /^twitter ログイン$/ do
  前提 %{twitter ログイン準備}
  visit '/auth/twitter'
end

もし /^情報を変更してログイン$/ do
  前提 %{twitter ログイン準備}
  OmniAuth.config.mock_auth[:twitter]["user_info"]["image"] =
    'http://example.com/sample_image2.png'
  OmniAuth.config.mock_auth[:twitter]["user_info"]["nickname"] = "tomy_kaira"
  visit '/auth/twitter'
end

前提 /^ログアウト$/ do
  visit destroy_user_session_path
end

もし /^twitter 用字句生成/ do
  @last_post_text = "cucumber をもちいたテスト投稿#{Time.now}"
  もし %{"内容"に"#{@last_post_text}"と入力する}
end

ならば /^"([^"]*)"に投稿されていること$/ do |service| #"
  if service  == "twitter"
    Twitter.configure do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.oauth_token = ENV['USER_TOKEN']
      config.oauth_token_secret = ENV['USER_SECRET']
    end
    Twitter.home_timeline[0].text.should be_include(@last_post_text)
  end
end

ならば /^"([^"]*)"に投稿されていないこと$/ do |service| #"
  if service  == "twitter"
    Twitter.configure do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.oauth_token = ENV['USER_TOKEN']
      config.oauth_token_secret = ENV['USER_SECRET']
    end
    Twitter.home_timeline[0].text.should_not be_include(@last_post_text)
  end
end

ならば /^(\d+)のサンプルアイコンが表示されていること$/ do |count|
  response.should have_selector "img[src='http://example.com/sample_image#{count}.png']"
end
