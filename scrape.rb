require 'watir'
require 'nokogiri'
require 'httparty'
require 'byebug'
require "csv"
require 'mechanize'
require "selenium-webdriver"

TIME_NOW = Time.now.getutc.to_i
URL = 'https://zoon.ru/msk/medical/'

if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

def med_centre_short
  CSV.open("result/med_centre_short.csv", "wb") do |csv|
    cards = Array.new
    browser = Watir::Browser.new
    browser.goto URL

    sleep(70)
    loop do
      break unless browser.span(class: "button-show-more").visible?
      browser.span(text: "Показать еще").wait_until(&:present?).click
      sleep(5)
    end

    tablet_listings = browser.ul(class: 'service-items-medium service-items-medium-hovered list-reset z-marker-events js-results-container')
    tablet_listings.each do |li|
      cards << li
    end
    puts cards.size
    cards.each_with_index do |li, index|

      title = li.div(class: 'service-description').div(class: 'H3').link.location.x != nil ?
                  li.div(class: 'service-description').div(class: 'H3').link.text : ""
      photo = li.div(class: 'bar js-photo-bar').location.x != nil ?
                  li.div(class: 'bar js-photo-bar').attribute_value("data-photos") : ""

      if li.div(class: 'service-description').div(class: 'address-info').location.x != nil
        desc = li.div(class: 'service-description').div(class: 'address-info').div(class: 'address-info-features invisible-links gray _fade').location.x != nil ?
               li.div(class: 'service-description').div(class: 'address-info').div(class: 'address-info-features invisible-links gray _fade').text : ""
        address = li.div(class: 'service-description').div(class: 'address-info').address(class: 'invisible-links _fade').location.x != nil ?
                  li.div(class: 'service-description').div(class: 'address-info').address(class: 'invisible-links _fade').text : ""
      else
        desc, address = ""
      end

      comment = li.div(class: 'service-description').div(class: 'last-comment simple-text rating-offset rel _fade').location.x != nil ?
                    li.div(class: 'service-description').div(class: 'last-comment simple-text rating-offset rel _fade').text : ""

      csv << [
          index + Time.now.strftime("%s").to_i,
          title, photo, desc, address, comment,
          Time.now.strftime("%Y-%d-%m %H:%M:%S")
      ]
    end
  rescue StandardError => e
    puts "e.message: #{e.message}"
  end
end

CSV.open("result/med_centre_short.csv", "w") do |csv|
  csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
  csv << %w(id title photo desc address comment updated_at )
end

med_centre_short