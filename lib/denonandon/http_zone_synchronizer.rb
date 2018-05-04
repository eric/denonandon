require 'denonandon/task'
require 'denonandon/http_client_2016'

module Denonandon
  class HttpZoneSynchronizer < Denonandon::Task
    def initialize(host)
      super()
      @client = Denonandon::HttpClient2016.new(host)
    end

    def run
      begin
        power_status = @client.power_status

        zone1_power = power_status['zone1']
        zone2_power = power_status['zone2']

        case
        when zone1_power == 'ON' && zone2_power != 'ON'
          log "zone1_power=#{zone1_power} zone2_power=#{zone2_power} action=power_on_zone2"
          @client.power_on_zone_2
        when zone1_power == 'OFF' && zone2_power == 'ON'
          log "zone1_power=#{zone1_power} zone2_power=#{zone2_power} action=power_off_zone2"
          @client.power_off_zone_2
        else
          # log "zone1_power=#{zone1_power} zone2_power=#{zone2_power}"
        end
      rescue => e
        log "exception=#{e.class} exception_message=#{e.message}"
      end

      sleep 3
    end

    def log(message)
      puts "http_zone_synchronizer: #{message}"
    end
  end
end