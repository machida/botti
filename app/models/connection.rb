# -*- coding: utf-8 -*-
class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :user, :foreign_key=>:friend_id
end
