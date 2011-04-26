# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

testuser_id = "123456"

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

ならば /^"([^"]*)"と"([^"]*)"に投稿されていること$/ do |content, service|
                         pending
                       end
