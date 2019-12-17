# https://www.youtube.com/watch?v=b3CLEUBdWwQ 14:37
# https://blog.devcenter.co/web-scraping-with-ruby-on-rails-67c5d3d133ff

require 'nokogiri'
require 'httparty'
require 'byebug'
require "csv"
require 'mechanize'

# необходимо для получения корректной кодировки при запуске скрипта на WINDOWS 10
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

def scraper
  CSV.open("main_category.csv", "wb") do |csv|
    tablets = Array.new
    csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
    csv << %w(id title url desc)
    url = 'https://apteka.103.by/lekarstva-minsk/'
    unparsed_page = HTTParty.get(url)
    parsed_page = Nokogiri::HTML(unparsed_page)
    tablet_listings = parsed_page.css('div.abc-list').css('div.col')
    tablet_listings.each do |tablet_listing|
      tablet_listing.css('ul.list').css('li').each_with_index do |listing, index|
        # byebug # точка останова
        csv << [
            index + 1,
            listing.css('a')[0].text,
            listing.css('a')[0].attributes['href'].value,
            listing.css('span.mnn-description')[0].text.include?('(~)') ? 'nil' : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
        ]
        tablet = {
            id: index + 1,
            title: listing.css('a')[0].text,
            url: listing.css('a')[0].attributes['href'].value,
            desc: listing.css('span.mnn-description')[0].text.include?('(~)') ? nil : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
        }
        tablets << tablet
      end
    end
    tablets
  end
end

def get_details(array)
  agent = Mechanize.new
  CSV.open("description.csv", "wb") do |csv|
    desc = Array.new
    csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
    csv << %w(title url desc)
    array.each do |el|
      # unparsed_page = HTTParty.get(el[:url])
      page = agent.get(el[:url])
      # parsed_page = Nokogiri::HTML(unparsed_page)
      # desc_parsing = parsed_page.css('a.drugsForm__header-instruction')
      desc_parsing = page.css('a.drugsForm__header-instruction')
      puts desc_parsing
      byebug # точка останова

      # desc_parsing.css('ul.list').css('li').each_with_index do |listing, index|
      #   # byebug # точка останова
      #   csv << [
      #       index + 1,
      #       listing.css('a')[0].text,
      #       listing.css('a')[0].attributes['href'].value,
      #       listing.css('span.mnn-description')[0].text.include?('(~)') ? 'nil' : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
      #   ]
      #   tablet = {
      #       id: index + 1,
      #       title: listing.css('a')[0].text,
      #       url: listing.css('a')[0].attributes['href'].value,
      #       desc: listing.css('span.mnn-description')[0].text.include?('(~)') ? nil : listing.css('span.mnn-description')[0].text.gsub(/\(|\) /, '')
      #   }
      #   desc << tablet
      # end
    end
  end
end

result = scraper
result = get_details(result)
p result.length
