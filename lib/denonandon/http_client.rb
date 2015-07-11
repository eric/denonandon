require 'net/http'
require 'denonandon/status'

module Denonandon
  class HttpClient
    def initialize(host)
      @uri = URI("http://#{host}/")

      @http = Net::HTTP.new(host, 80)
      @http.open_timeout = 5 # in seconds
      @http.read_timeout = 5 # in seconds
    end

    def request(path, params = nil)
      params ||= {}
      uri = @uri.dup

      uri.path = path

      unless params.empty?
        uri.query = URI.encode_www_form(params)
      end

      case res = @http.request(Net::HTTP::Get.new(uri.request_uri))
      when Net::HTTPSuccess, Net::HTTPRedirection
        res
      else
        res.error!
      end
    end

    def status(zone = nil)
      if zone
        params = { :ZoneName => zone }
      end

      Status.new(request('/goform/formMainZone_MainZoneXml.xml', params).body)
    end

    # PutSystem_OnStandby/STANDBY
    # PutSystem_OnStandby/ON
    # PutZone_OnOff/OFF
    # PutZone_OnOff/ON
    # PutZone_InputFunction/GAME
    # PutZone_InputFunction/SAT/CBL
    # PutSurroundMode/DOLBY DIGITAL
    # PutSurroundMode/MCH STEREO
    # PutSurroundMode/MOVIE
    # PutSurroundMode/MUSIC
    # PutSurroundMode/GAME
    # PutSurroundMode/PURE DIRECT
    # PutSurroundMode/DIRECT
    # PutSurroundMode/STEREO
    # PutSurroundMode/STANDARD
    # PutSurroundMode/SIMULATION
    # PutSurroundMode/AUTO
    # PutSurroundMode/LEFT
    # PutSurroundMode/STEREO
    # PutMasterVolumeBtn/<
    # PutMasterVolumeBtn/>
    # PutVolumeMute/ON
    # PutVolumeMute/OFF
    # PutMasterVolumeSet/50
    # PutZone_InputFunction/
    # PutSleepTimer/

    def command(commands, zone = nil)
      params = {}

      if zone
        params[:ZoneName] = zone
      end

      Array(commands).flatten.each_with_index do |cmd, idx|
        params["cmd#{idx}"] = cmd
      end

      request("/MainZone/index.put.asp", params)
    end
  end
end