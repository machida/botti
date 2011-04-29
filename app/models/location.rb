class Location < ActiveRecord::Base
  acts_as_mappable :default_units=>:kms, :default_formula=>:flat

  attr_accessible :lat, :lng
end
