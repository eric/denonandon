require 'net/http'
require 'denonandon/status'

module Denonandon
  class HttpClient2016
    def initialize(host, port = 8080)
      @uri = URI("http://#{host}/")

      @http = Net::HTTP.new(host, port)
      @http.open_timeout = 5 # in seconds
      @http.read_timeout = 5 # in seconds
    end

    def request(path, params = nil)
      params ||= {}
      uri = @uri.dup

      uri.path = path

      unless params.empty?
        if params.is_a?(String)
          uri.query = params
        elsif params.is_a?(Hash)
          uri.query = URI.encode_www_form(params)
        end
      end

      case res = @http.request(Net::HTTP::Get.new(uri.request_uri))
      when Net::HTTPSuccess, Net::HTTPRedirection
        res
      else
        res.error!
      end
    end

    def post_request(path, body = nil)
      uri = @uri.dup
      uri.path = path

      post = Net::HTTP::Post.new(uri.request_uri)
      post.content_type = 'text/xml; charset=utf-8'
      post.body = body

      case res = @http.request(post)
      when Net::HTTPSuccess, Net::HTTPRedirection
        res
      else
        res.error!
      end
    end

    def power_status
      xml = %{<cmd id="1">GetAllZonePowerStatus</cmd>}

      body = app_command(xml).body
      doc = REXML::Document.new(body)

      hash = {}
      if cmd = REXML::XPath.first(doc, "//rx/cmd")
        cmd.elements.each do |child|
          hash[child.name] = child.text.strip
        end
      end

      hash
    end

    def power_on_zone_1
      request("/goform/formiPhoneAppPower.xml", "1+PowerOn")
    end

    def power_off_zone_1
      request("/goform/formiPhoneAppPower.xml", "1+PowerStandby")
    end

    def power_on_zone_2
      request("/goform/formiPhoneAppPower.xml", "2+PowerOn")
    end

    def power_off_zone_2
      request("/goform/formiPhoneAppPower.xml", "2+PowerStandby")
    end

    def app_command(data)
      xml = %{<?xml version="1.0" encoding="utf-8" ?>\n<tx>#{data}</tx>}
      post_request("/goform/AppCommand.xml", xml)
    end
  end
end