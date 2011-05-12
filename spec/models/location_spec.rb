# -*- coding: utf-8 -*-
require 'spec_helper'

describe Location do
  before do
    @lat = 35.65947338278833
    @lng = 139.6847677240835
  end

  describe "mapping" do
    before do
      @l = [Location.create!(:lat=>@lat, :lng=>@lng),
        Location.create!(:lat=>@lat, :lng=>@lng+1E-5),
        Location.create!(:lat=>@lat, :lng=>@lng+1E-1)]
    end

    it { Location.count.should == 3 }
    context "within 10kms" do
      subject {Location.within(1,
                        :origin=>[@lat,@lng])}
      its(:count) { should == 2 }
      its(:first) { should == @l[0] }
    end

    describe "within 10kms, ordered" do
      # a too small gap cannot be detected by Array#sort_by_distance_from
      # order("distance") and order("distance DESC") returns the same
      subject do
        Location.within(1,:origin=>[@lat,@lng]).sort_by_distance_from([@lat,@lng])
      end
      its(:count) { should == 2 }
      its(:first) { should == @l[0]}
      its(:last) { should == @l[1] }
    end
  end

  describe "custom new" do
    it "should make new Location from LatLng object" do
        l = Location.create!(Geokit::LatLng.normalize("35,135"))
        l.lat.should == 35
    end

    it "should make new Location from String" do
        l = Location.create!("35, 150")
        l.lat.should == 35
    end

    it "should make new Location from Array" do
      Location.new([35,150]).lat.should == 35
    end
  end

  describe "when loaded from database" do
    before do
      Location.count.should == 0 ## gauntlet
      Location.create!("#{@lat}, #{@lng}")
    end

    subject { Location.all }
    its(:count) {should == 1}
    its("first.lat") {should == BigDecimal(@lat.to_s)}
    its("first.lng") {should == BigDecimal(@lng.to_s)}
  end
end
