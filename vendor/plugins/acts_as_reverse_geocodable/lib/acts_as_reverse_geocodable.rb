# -*- coding: utf-8 -*-
# ActsAsReverseGeocodable
module ActiveRecord
module Acts
  module ReverseGeocodable
    def self.included(base)
      base.extend ActMacro
    end
    REQUEST_LANG = "ja"
    GOOGLE_API_VERSION = 3
    PROXY = {:addr=> nil, :port=> nil, :user=> nil, :pass=> nil}

    def auto_geocode
      url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{self.lat},#{self.lng}&language=ja&sensor=false"

      res = ActiveRecord::Acts::ReverseGeocodable.get_response url
      address = ActiveRecord::Acts::ReverseGeocodable.get_address(res.body)

      self.send("#{field}=", address)
    end

    module ActMacro
      class NoLocationColumnError < StandardError; end
      def acts_as_reverse_geocodable(colname = "address")
        # existence/type check of the field
        raise NoLocationColumnError unless self.column_names.include? colname
        raise TypeError unless self.columns_hash[colname].type.equal? :string

        cattr_accessor :field
        self.field = colname
        before_validation :auto_geocode, :on => :create
      end
    end

    def self.get_response(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(url)
      req.basic_auth(uri.user, uri.password) if uri.userinfo
      res = Net::HTTP::Proxy(PROXY[:addr],PROXY[:port],PROXY[:user],PROXY[:pass]).start(uri.host, uri.port) { |http| http.get(uri.path + "?" + uri.query) }
      return res
    end

    def self.get_address(json)
      a = JSON.parse(json)
      begin
        # no need for a postal code
        if a["results"][0]["formatted_address"].include? "〒"
          a["results"][1]["formatted_address"]
        else
          a["results"][0]["formatted_address"]
        end
      rescue NoMethodError
        ""  # if the element does not exist
      end
    end
  end
end
end
