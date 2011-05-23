# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

def config_twitter
  Twitter.configure do |config|
    config.consumer_key = ENV['CONSUMER_KEY']
    config.consumer_secret = ENV['CONSUMER_SECRET']
    config.oauth_token = ENV['USER_TOKEN']
    config.oauth_token_secret = ENV['USER_SECRET']
  end
end

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
  @backup_info = OmniAuth.config.mock_auth[:twitter]['user_info'].clone
  OmniAuth.config.mock_auth[:twitter]["user_info"]["image"] =
    'http://example.com/sample_image2.png'
  OmniAuth.config.mock_auth[:twitter]["user_info"]["nickname"] = "tomy_kaira"
  visit '/auth/twitter'
end

もし /^もとにもどす$/ do
  OmniAuth.config.mock_auth[:twitter]['user_info'] = @backup_info
end

前提 /^ログアウト$/ do
  visit destroy_user_session_path
end

もし /^"([^"]*)"に twitter 用字句生成/ do |form| #"
  case form
  when "つぶやき"
    @post_text = "cucumber をもちいたテスト投稿#{Time.now}"
    もし %{"内容"に"#{@post_text}"と入力する}
    set_hidden_field "tweet_ll", :to=>"35.647401,139.716911"
  when "メッセージ"
    @message_text = "いくいく #{Time.now}"
    もし %{"message"に"#{@message_text}"と入力する}
  else
    pending
  end
end

ならば /^"([^"]*)"に投稿されていること$/ do |service| #"
  if service  == "twitter"
    config_twitter
    Twitter.home_timeline[0].text.should be_include(@post_text)
    Twitter.home_timeline[0].text.should be_include(ENV['TWITTER_SUFFIX'])
  end
end

ならば /^"([^"]*)"に投稿されていないこと$/ do |service| #"
  if service  == "twitter"
    config_twitter
    Twitter.home_timeline[0].text.should_not be_include(@post_text)
  end
end

ならば /^(\d+)のサンプルアイコンが表示されていること$/ do |count|
  response.should have_selector "img[src='http://example.com/sample_image#{count}.png']"
end

ならば /ログインできること/ do
  response.should have_selector "img[src^='/images/sign-in-with-twitter-l.png']"
end

ならば /DMが送信されていること/ do
  config_twitter
  dm = Twitter.direct_messages_sent(:count => 1)[0]
  dm.text.should be_include(@message_text)
end

ならば /DMが送信されていないこと/ do
  config_twitter
  dm = Twitter.direct_messages_sent(:count => 1)[0]
  dm.text.should be_include(@message_text)
end
