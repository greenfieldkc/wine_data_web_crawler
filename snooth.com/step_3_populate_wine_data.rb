require 'bundler'
Bundler.require(:crawler)

require 'open-uri'
require 'pp'

require_relative '../../lib/execution_timer'
require_relative '../../lib/text_filter'
require_relative '../../models/wine'
require_relative '../../models/wine_doc'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper::database  = "snooth"
MongoMapper::Document.plugin(MongoMapper::Plugins::IdentityMap)

def main
  timer = ExecutionTimer.new

  timer.time_this do
    populate_wine_data
  end

  puts "There are now #{Wine.count} documents in wines collection."
  puts "It took #{timer.last_execution_time} to run this script.\n\n"
end

def populate_wine_data
  WineDoc.each_chunk :query => WineDoc.where do |wine_docs|
    wine_docs.each do |wine_doc|
      unless wine_doc.html.nil?
        doc = Nokogiri::HTML wine_doc.html

        wine_name    = extract_wine_name doc
        wine_vintage = extract_wine_vintage doc
        wine_url     = wine_doc.url

        wine_key = { name:wine_name, vintage:wine_vintage, url:wine_url }
  
        # Find a matching wine
        wine = Wine.where(wine_key).first
  
        # If wine doesn't already exist, create a new wine and associate a blank winemaker's note
        if wine.nil?
          wine = Wine.new(wine_key); wine.save
          note = WinemakerNote.new;  note.save
          wine.push(:note_ids => note.id)
        end

        # Now update the winemaker's note
        note                = wine.maker_notes.first
        note.text           = extract_raw_winemaker_notes doc
        note.processed_text = TextFilter.scrub note.text
        note.save
      end
    end
  end
end

def extract_wine_name(doc)
  doc.at_css('h1#wine-name').content.gsub(/\n/, "").gsub(/\s+/, " ").strip
end

def extract_wine_vintage(doc)
  wine_headline = extract_wine_name doc
  year_in_title = wine_headline.match(/\d{4}/)
  year_in_title[0] if year_in_title
end

def extract_raw_winemaker_notes(doc)
  doc.at_css('div#help-notes p').nil? ? "" : doc.at_css('div#help-notes p').content.strip
end

main