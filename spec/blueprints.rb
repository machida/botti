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
end

# Room.blueprint do
#   name
#   description
#   lastpost { Time.now }
# end

Authentication.blueprint do
  provider "faker"
  uid
  token
  secret
end

User.blueprint do
  authentications { [Authentication.make] }
  email
  nickname
end

User.blueprint(:login) do
  email
  nickname
end
