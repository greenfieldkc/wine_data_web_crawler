require 'bundler'
Bundler.require(:crawler)

require 'pp'

require_relative '../../lib/execution_timer'
require_relative '../models/wine_link'
require_relative 'lib/wine_links_scraper'

MongoMapper::database = "snooth"
MongoMapper::Document.plugin(MongoMapper::Plugins::IdentityMap)

def main
  num_pages_to_crawl = 1500

  timer = ExecutionTimer.new
  
  timer.time_this do
    crawl_for_wine_links num_pages_to_crawl
  end

  wine_links_doc = WineLink.where(:crawl_source => "snooth.com").first

  puts "\n"
  puts "Finished crawling. [Crawled #{num_pages_to_crawl} pages.]\n"
  puts "Number of unique wine links collected so far: #{wine_links_doc.links.size}"
  puts "It took #{timer.last_execution_time} to run this script.\n\n"  
end

def crawl_for_wine_links(num_pages_to_crawl)
  links_scraper    = Snooth::Crawler::WineLinksScraper.new :throttle_speed => 0.05
  links_enumerator = links_scraper.to_enum

  # clear_wine_links_document
  
  wine_links_doc = WineLink.where(:crawl_source => "snooth.com").first
  wine_links_doc = WineLink.create(:crawl_source => "snooth.com", :links => []) if wine_links_doc.nil?

  print "\nCrawling for links"

  links_enumerator.each_page(num_pages_to_crawl) do |page_data, page_num|
    print "."
    wine_links_doc.links.concat(page_data[:links]).sort!.uniq!
    wine_links_doc.save!
  end
end

def clear_wine_links_document
  WineLink.where(:crawl_source => "snooth.com").all.map(&:delete)
end

main
