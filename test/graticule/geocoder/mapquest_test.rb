# encoding: UTF-8
require 'test_helper'

module Graticule
  module Geocoder
    class MapquestTest < Test::Unit::TestCase
      def setup
        URI::HTTP.responses = []
        URI::HTTP.uris = []
        @geocoder = Mapquest.new('client_id', 'password')
      end

      def test_success
        prepare_response(:success)
        location = Location.new(
          :country => "US",
          :latitude => 44.152019,
          :locality => "Lovell",
          :longitude => -70.892706,
          :postal_code => "04051-3919",
          :precision => :address,
          :region => "ME",
          :street => "44 Allen Rd"
        )
        assert_equal(location, @geocoder.locate('44 Allen Rd., Lovell, ME 04051'))
      end

      def test_multi_result
        prepare_response(:multi_result)
        location = Location.new(
          :country => "US",
          :latitude => 40.925598,
          :locality => "Stony Brook",
          :longitude => -73.141403,
          :postal_code => nil,
          :precision => :locality,
          :region => "NY",
          :street => nil
        )
        assert_equal(location, @geocoder.locate('217 Union St., NY'))
      end

      def test_query_construction
        request = Mapquest::Request.new("217 Union St., NY", 1234, "password")
        query = %Q{e=5&<?xml version="1.0" encoding="ISO-8859-1"?><Geocode Version="1">\
<Address><Street>217 Union St., NY</Street></Address><GeocodeOptionsCollection Count="0"/>\
<Authentication Version="2"><Password>password</Password><ClientId>1234</ClientId></Authentication></Geocode>}
        assert_equal(query, request.query)
      end

      def test_xml_escaping
        request = Mapquest::Request.new("State & Main", 1234, "password")
        assert_equal(request.escaped_address, "State &amp; Main")
      end

      protected

      def prepare_response(id)
        URI::HTTP.responses << response('mapquest', id)
      end
    end
  end
end
