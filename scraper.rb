# https://www.youtube.com/watch?v=b3CLEUBdWwQ 14:37
# https://blog.devcenter.co/web-scraping-with-ruby-on-rails-67c5d3d133ff

require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  url = 'https://apteka.103.by/lekarstva-minsk/'
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
  tablets = Array.new
  tablet_listings = parsed_page.css('')
  tablet_listings.each do |tablet_listing|
    tablet = {
      title: tablet_listing.css('').text,
      desc: tablet_listing.css('').text
    }
    tablets << tablet
  end
  byebug # точка останова
end

scraper
