# Include hook code here
require 'acts_as_reverse_geocodable'
require 'geokit'
require 'open-uri'
require 'json'

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::ReverseGeocodable
end
