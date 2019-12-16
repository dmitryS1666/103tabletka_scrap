# https://www.youtube.com/watch?v=b3CLEUBdWwQ 14:37
# https://blog.devcenter.co/web-scraping-with-ruby-on-rails-67c5d3d133ff

require 'nokogiri'
require 'httparty'
require 'byebug'
require "csv"

# необходимо для получения корректной кодировки при запуске скрипта на WINDOWS 10
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

def scraper
  CSV.open("file.csv", "wb") do |csv|
    csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
    csv << %w(title url desc)
    url = 'https://apteka.103.by/lekarstva-minsk/'
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    tablets = Array.new
    tablet_listings = parsed_page.css('div.abc-list').css('div.col')
    tablet_listings.each do |tablet_listing|
      tablet_listing.css('ul.list').css('li').each do |listing|
        # byebug # точка останова
        csv << [
            listing.css('a')[0].text,
            listing.css('a')[0].attributes['href'].value,
            listing.css('span.mnn-description')[0].text.include?('(~)') ? 'nil' : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
        ]
        tablet = {
            title: listing.css('a')[0].text,
            url: listing.css('a')[0].attributes['href'].value,
            desc: listing.css('span.mnn-description')[0].text.include?('(~)') ? nil : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
        }
        tablets << tablet
      end
    end
    puts 'tablets', tablets
  end

  #byebug # точка останова
end

scraper
