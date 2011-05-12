class Location < ActiveRecord::Base
  belongs_to :tweet
  acts_as_mappable :default_units=>:kms, :default_formula=>:flat
  attr_accessible :lat, :lng

  private
  def initialize(args)
    begin
      ll = Geokit::LatLng.normalize(args)
      super(:lat=>ll.lat, :lng=>ll.lng)
    rescue
      super
    end
  end
end
