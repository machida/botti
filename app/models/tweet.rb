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
    self.save!
  end

  def self.remove_old_tweets
    self.delete_all(["updated_at < ?", 3.days.ago])
  end

  def as_json(options = {})
    p "called"
    options[:dm] ||= true
    {
      :content => content,
      :time => time,
      :dm => options[:dm] ? id : "",
      :location => {
        :address => location.address,
        :lat => location.lat,
        :lng => location.lng
      },
      :user => {:name => user.nickname, :image_url => user.image_url}
    }
  end
  #   %Q% googlemap_controller.addFriend(#{params.to_json});%
end
