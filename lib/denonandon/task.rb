require 'atomic'

module Denonandon
  class Task
    def initialize
      @running = Atomic.new(false)
      @thread  = Atomic.new(nil)
    end
    
    def start
      @running.value = true

      @thread.value = Thread.new do
        Thread.current.abort_on_exception = true
        
        while @running.value
          run
        end
      end
    end
    
    def stop
      @running.value = false
    end
    
    def join
      if t = @thread.value
        t.join
      end
    end
  end
end