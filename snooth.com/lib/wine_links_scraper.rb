require 'open-uri'

require_relative 'crawler_base'
require_relative 'enumerator_methods'

module Snooth
  module Crawler

    class WineLinksScraper < Snooth::Crawler::Base
      def initialize(opts = {})
        super
        @starting_url     = "http://www.snooth.com/wines/"
        @next_page_url    = @starting_url
        @current_page_url = @starting_url
      end

      def get_next_page_of_links
        doc = @next_page_url.nil? ? nil : Nokogiri::HTML(open(@next_page_url))
        @current_page_url = @next_page_url
        @next_page_url    = extract_next_page_link doc
        extract_wine_links_from_page doc
      end
  
      def have_more_pages_of_links?
        not @next_page_url.nil?
      end
  
      def extract_wine_links_from_page(doc)
        doc.search('div.wine-name a').map { |a_link| a_link["href"] unless a_link["href"] == "#" }.compact
      end
  
      def extract_next_page_link(doc)
        current_page_num = doc.search('a.current-page').children.first.content.to_i
        next_page_link   = doc.search('a.fs-page').find { |link| (current_page_num + 1) == link.content.to_i }
        next_page_link["href"] unless next_page_link.nil?
      end

      def reset
        @next_page_url    = @starting_url
        @current_page_url = @starting_url
      end

      def crawl
        while have_more_pages_of_links?
          links_on_page = get_next_page_of_links
          page_data = { url:@current_page_url, links:links_on_page }
          yield page_data
          throttle
        end
      end

      def to_enum
        self.enum_for(:crawl).extend(Snooth::Crawler::EnumeratorMethods)
      end
    end

  end
end
