# -*- coding: utf-8 -*-
ならば /投稿フォームが表示されていること$/ do
  response.should have_selector "form"
end

ならば /投稿フォームが表示されていないこと$/ do
  response.should_not have_selector "form"
end
