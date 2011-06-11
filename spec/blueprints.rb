# -*- coding: utf-8 -*-
require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  nickname { Faker::Name.last_name }
  uid { rand(100000).to_s }
  token { rand(100000).to_s + "-" + rand(100000).to_s }
  secret { rand(100000).to_s }
  email { Faker::Internet.email }
  url { "http://www.example.com/" + Faker::Internet.user_name + ".png" }
  content { Faker::Lorem.sentence }
  geo { rand(100000) / 1000.0 }
end

Authentication.blueprint do
  provider "twitter"
  uid
  token
  secret
end

User.blueprint do
  authentications { [Authentication.make] }
  email
  nickname
  image_url { Sham.url }
end

User.blueprint(:login) do
  email
  nickname
end

Location.blueprint do
  lat { Sham.geo }
  lng { Sham.geo }
end

Tweet.blueprint do
  user { User.make }
  content
  location { Location.new([10,20]) }
end
