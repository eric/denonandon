require 'denonandon/task'
require 'denonandon/http_client'

module Denonandon
  class HttpZoneSynchronizer < Denonandon::Task
    def initialize(host)
      super()
      @client = Denonandon::HttpClient.new(host)
    end

    def run
      begin
        main_zone_status = @client.status
        zone2_status     = @client.status('ZONE2')
        
        zone1_power = main_zone_status['ZonePower']
        zone2_power = zone2_status['ZonePower']
        
        case
        when zone1_power == 'ON' && zone2_power != 'ON'
          puts "zone1_power=#{zone1_power} zone2_power=#{zone2_power} action=power_on_zone2"
          @client.command 'PutZone_OnOff/ON', 'ZONE2'
        when zone1_power == 'OFF' && zone2_power == 'ON'
          puts "zone1_power=#{zone1_power} zone2_power=#{zone2_power} action=power_off_zone2"
          @client.command 'PutZone_OnOff/OFF', 'ZONE2'
        else
          puts "zone1_power=#{zone1_power} zone2_power=#{zone2_power}"
        end
      rescue => e
        puts "synchronizer: #{e}"
      end

      sleep 3
    end
  end
end