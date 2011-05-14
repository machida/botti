class Tweet < ActiveRecord::Base
  has_one :location, :dependent=>:delete
  belongs_to :user
  attr_accessor :ll, :ontwitter
  attr_accessible :content, :user_id, :ll
  validates_presence_of :content, :user_id

  def set_location
    unless ll.blank?
      obj = Geokit::LatLng.normalize(ll)
      self.location = Location.new(:lat=>obj.lat, :lng=>obj.lng)
      self.save
    end
  end
end
