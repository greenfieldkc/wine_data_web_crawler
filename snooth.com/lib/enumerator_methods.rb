module Snooth
  module Crawler
    
    module EnumeratorMethods
      def each_page(num_items, &block)
        begin
          1.upto(num_items) { |page| block.call(self.next, page) if block_given? }
        rescue StopIteration
        end
      end
    end
    
  end
end
