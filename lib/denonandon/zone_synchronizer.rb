require 'denonandon/task'
require 'denonandon/session'

module Denonandon
  class ZoneSynchronizer < Denonandon::Task
    def initialize(host)
      super()
      @session = Denonandon::Session.new(host, method(:event_handler))
    end

    def event_handler(event)
      case event
      when 'PWON'
        @power = :on
      when 'PWSTANDBY'
        @power = :off
      when 'ZMON'
        @zone1_power = :on
      when 'ZMOFF'
        @zone1_power = :off
      when 'Z2ON'
        @zone2_power = :on
      when 'Z2OFF'
        @zone2_power = :off
      end

      puts "-> #{event}"
    end

    def start
      @session.start
      super
    end

    def stop
      @session.stop
      super
    end

    def join
      @session.join
      super
    end

    def run
      puts "power=#{@power} zone1_power=#{@zone1_power} zone2_power=#{@zone2_power}"

      begin
        @session.command 'PW?'
        @session.command 'ZM?'
        @session.command 'Z2?'
        
        if @zone1_power == :on && @zone2_power == :off
          @session.command 'Z2ON'
        elsif @zone1_power == :off && @zone2_power == :on
          @session.command 'Z2OFF'
        end
      rescue => e
        puts "synchronizer: #{e}"
      end

      sleep 5
    end
  end
end