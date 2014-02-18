require 'bundler'
Bundler.require(:crawler)

require 'open-uri'
require 'pp'

require_relative '../../lib/execution_timer'
require_relative '../models/wine_link'
require_relative '../models/wine_doc'

MongoMapper::database = "snooth"
MongoMapper::Document.plugin(MongoMapper::Plugins::IdentityMap)

$shutdown = false

trap("INT") do
  $shutdown = true
end

def main
  timer = ExecutionTimer.new
  
  timer.time_this do
    spider_wine_links
  end
  
  puts "\n"
  puts "All links spidered."
  puts "There are now #{WineDoc.count} documents in wine_docs collection."
  puts "It took #{timer.last_execution_time} to run this script.\n\n"
end

def spider_wine_links
  wine_links_doc = WineLink.where(:crawl_source => "snooth.com").first

  # clear_wine_docs_collection

  links_not_yet_spidered = wine_links_doc.links.select do |link|
    WineDoc.where(:crawl_source => "snooth.com", :url => link).fields(:_id).first.nil?
  end
  
  links_not_yet_spidered.each do |link|
    puts "Spidering link: #{link}"
    html_doc = open(link).read
    WineDoc.create(:crawl_source => "snooth.com", :url => link, :html => html_doc).save!
    throttle
    break if $shutdown
  end
end

def clear_wine_docs_collection
  WineDoc.collection.remove
end

def throttle
  sleep 0.1
end

main