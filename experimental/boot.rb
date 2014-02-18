# encoding: utf-8

gemfile = File.expand_path('../Gemfile', __FILE__)

begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.require
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)


begin
  puts "#{__FILE__}"
end