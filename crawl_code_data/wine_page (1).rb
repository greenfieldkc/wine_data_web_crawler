require 'bundler'
Bundler.require

require 'open-uri'

doc = Nokogiri::HTML(open("http://www.snooth.com/wine/paso-a-paso-verdejo-2010/"))

wine_name = []
doc.search('div.wine-header h1').children.each {|element| wine_name<<element}
wine_name = wine_name[0]
puts wine_name  
vintage = doc.search('div.wine-header h1 a').children
puts vintage

varietal = doc.search('dd.varietal a').children
puts varietal

tags = []
doc.search('div.wp-user-tags a').each {|element| tags << element.children}
##tags.delete_if{|item| item.ascii_only? == false}  
puts tags


=begin
user_reviews = {} #returns hash: key=username, value=review text
user = doc.search('div.user-name span').children
review = doc.search('p wp-wine-review-text').children
#puts user
puts review
=end

winemaker_review = doc.search('div.helper p').children
puts winemaker_review
