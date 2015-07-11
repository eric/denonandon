require 'denonandon/task'
require 'denonandon/tcp_socket'

module Denonandon
  class Session < Denonandon::Task
    def initialize(host, callback = nil, &block)
      super()

      @host     = host
      @callback = callback || block

      @mutex = Mutex.new
      @buffer = ''
    end
    
    def reopen
      @mutex.synchronize do
        @buffer = ''

        if @socket          
          @socket.close
          @socket = nil
        end
      end
    end
    
    def socket
      @mutex.synchronize do
        @socket ||= Denonandon::TcpSocket.connect(:host => @host, :port => 23,
          :read_timeout => 5, :connect_timeout => 5)
      end
    end
      
    def command(data)
      socket.write(data + "\r")
      sleep 0.3
    rescue
      reopen
      raise
    end
    
    def run
      begin
        socket.readpartial(1024, @buffer)
      rescue Denonandon::TcpSocket::Timeout
        # We don't really care
      rescue
        reopen
        sleep 1
      end
      
      puts "buffer: #{@buffer.inspect}"
      
      while line = @buffer.slice!(/^(.*?)\r/)
        line.chomp!
        
        @callback.call(line)
      end
    end
  end
end