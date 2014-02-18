require 'open-uri'

require 'bundler'
Bundler.require


screened_links = []
1.upto(2).each do |n| 
doc = Nokogiri::HTML(open("http://www.snooth.com/wines//?luid=66&ttl=1338595018768&search_page=#{n}"))
links = doc.search('div.wine-name a')
links.each {|link|
  if link["href"] != "#"
    screened_links << link["href"]
  end
  }
end
puts screened_links
puts "screened_links length = #{screened_links.length}"

f = File.open('./data/top_level_links.txt', 'w')
screened_links.each { |link| f.puts link }

