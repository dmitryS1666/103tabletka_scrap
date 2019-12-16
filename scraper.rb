# https://www.youtube.com/watch?v=b3CLEUBdWwQ 14:37
# https://blog.devcenter.co/web-scraping-with-ruby-on-rails-67c5d3d133ff

require 'nokogiri'
require 'httparty'
require 'byebug'
require "csv"

def scraper
  url = 'https://apteka.103.by/lekarstva-minsk/'
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  tablets = Array.new
  tablet_listings = parsed_page.css('div.abc-list').css('div.col')
  tablet_listings.each do |tablet_listing|
    tablet_listing.css('ul.list').css('li').each do |listing|
      # byebug # точка останова
      tablet = {
          title: listing.css('a')[0].text,
          url: listing.css('a')[0].attributes['href'].value,
          desc: listing.css('span.mnn-description')[0].text.include?('(~)') ? nil : listing.css('span.mnn-description')[0].text
      }
      tablets << tablet
    end
  end
  puts 'tablets', tablets
  CSV.open("file.csv", "wb") do |csv|
    csv << %w(title url desc)
    csv << tablets
  end

  #byebug # точка останова
end

scraper
