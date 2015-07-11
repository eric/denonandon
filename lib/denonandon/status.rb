require 'rexml/document'

module Denonandon
  class Status
    def initialize(data)
      decode(data)
    end
    
    def [](value)
      @hash[value]
    end
    
    def decode(data)
      doc = REXML::Document.new(data)
      
      @hash = {}
      doc.elements.each("//value") do |element|
        if element.text
          @hash[element.parent.name] = element.text.strip
        end
      end
    end
  end
end