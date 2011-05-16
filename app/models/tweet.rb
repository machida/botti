# -*- coding: utf-8 -*-
class Tweet < ActiveRecord::Base
  has_one :location, :dependent=>:delete
  belongs_to :user
  attr_accessor :ll, :ontwitter
  attr_accessible :content, :user_id, :ll
  validates_presence_of :content, :user_id
  validates_length_of :content, :maximum => 140

  def set_location
    obj = Geokit::LatLng.normalize(ll)
    self.location = Location.create!(:lat=>obj.lat, :lng=>obj.lng)
    self.save
  end

  def time
    updated_at.in_time_zone("Tokyo").strftime("%H:%M %d日")
  end
end
