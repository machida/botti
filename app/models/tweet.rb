class Tweet < ActiveRecord::Base
  has_one :location, :dependent=>:delete
  belongs_to :user
  attr_accessor :ll
  attr_accessible :content, :user_id, :ll
  validates_presence_of :content, :user_id

  def set_location
    unless ll.blank?
      obj = Geokit::LatLng.normalize(ll)
      if self.location = Location.new(:lat=>obj.lat, :lng=>obj.lng)
        self.location.address = Geokit::Geocoders::GoogleGeocoder.reverse_geocode(ll).full_address
      end
      self.save
    end
  end
end
