# -*- coding: utf-8 -*-
require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  # name { Faker::Name.first_name }
  # description { Faker::Lorem.paragraphs(1) }
end

# Room.blueprint do
#   name
#   description
#   lastpost { Time.now }
# end
