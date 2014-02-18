module Snooth
  module Crawler
    
    class Base
      def initialize(opts = {})
        @opts = { :enable_throttle => true, :throttle_speed => 5.0 }.merge(opts)
      end

      def throttle
        sleep @opts[:throttle_speed] if @opts[:enable_throttle]
      end
    end

  end
end
