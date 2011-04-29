# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

@last_post_text = ""

前提 /^twitter アカウントを登録している/ do
  前提 %{twitter ログイン}
  前提 %{ログアウト}
end

前提 /^twitter ログイン準備$/ do
  OmniAuth.config.mock_auth[:twitter] = {
    'uid' => '123456',
    'user_info' => {
      'name'=>'Shiken Tarou',
      'nickname'=>'s_tarou',
      'description' => 'This is TestAccount'
    },
    'credentials' => {
      'token' => 'TODO',
      'secret' => 'TODO'
    },
    'provider' => 'twitter'
  }
end

前提 /^twitter ログイン$/ do
  前提 %{twitter ログイン準備}
  visit '/auth/twitter'
end

前提 /^ログアウト$/ do
  visit destroy_user_session_path
end

もし /^twitter 用字句生成/ do
  @last_post_text = "cucumber をもちいたテスト投稿#{Time.now}"
  もし %{"内容"に"#{@last_post_text}"と入力する}
end

ならば /^"([^"]*)"に投稿されていること$/ do |service|
  if service  == "twitter"
    Twitter.configure do |config|
      config.consumer_key = 'TODO'
      config.consumer_secret = 'TODO'
      config.oauth_token = 'TODO'
      config.oauth_token_secret = 'TODO'
    end
    Twitter.home_timeline[0].text.should be_include(@last_post_text)
  end
end
