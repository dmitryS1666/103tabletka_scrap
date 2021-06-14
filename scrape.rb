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

def main_categories
  # CSV.open("result/main_category.csv", "wb") do |csv|
  tablets = Array.new
  browser = Watir::Browser.new
  browser.goto URL

  # sleep(10000)
  # doc = Nokogiri::HTML.parse(browser.html)
  # button = doc.at('span.js-next-page.button.button-show-more.button-block.button-primary')
  loop do
    break unless browser.span(class: "button-show-more").visible?
    browser.span(text: "Показать еще").wait_until(&:present?).click
    sleep(5)
  end

  # tablet_listings = parsed.css('ul.service-items-medium.service-items-medium-hovered.list-reset.z-marker-events.js-results-container')
  # puts tablet_listings
  # count = 0
  # parsed.css('ul.service-items-medium.service-items-medium-hovered.list-reset.z-marker-events.js-results-container').css('li').each_with_index do |listing, index|
  #   count += 1
  # end
  # puts count

  # tablet_listings.each do |tablet_listing|
  #   tablet_listing.css('ul.list').css('li').each_with_index do |listing, index|
  #     csv << [
  #         index + Time.now.strftime("%s").to_i,
  #         listing.css('a')[0].text,
  #         listing.css('a')[0].attributes['href'].value,
  #         Time.now.strftime("%Y-%d-%m %H:%M:%S")
  #     ]
  #     tablet = {
  #         id: index + Time.now.strftime("%s").to_i,
  #         title: listing.css('a')[0].text,
  #         url: listing.css('a')[0].attributes['href'].value,
  #         updated_at: Time.now.strftime("%Y-%d-%m %H:%M:%S")
  #     }
  #     tablets << tablet
  #   end
  # end
  # tablets

rescue StandardError => e
  puts "e.message: #{e.message}"
  # end
end

def get_details(array)
  CSV.open("result/description_short_#{TIME_NOW}.csv", "wb") do |csv|
    browser = Watir::Browser.new :chrome, headless: true
    array.each_with_index do |el, index|
      next if index < 3917 || index == 3917
      puts "index: #{index}"
      url = el[:url]
      browser.goto url
      sleep(4)
      # browser.link(text: "Инструкция").when_present.click
      browser.link(text: "Инструкция").fire_event('click')
      sleep(1)

      main_div = browser.div(class: /^instructionPopup__drugInfo$/)
      main_div.divs.each do |child|
        if child.h2.present? && child.span.present?
          csv << [ index + Time.now.strftime("%s").to_i, el[:id], el[:title], child.h2.text + child.span.text, Time.now.strftime("%Y-%d-%m %H:%M:%S") ]
        end
      end

      additional_div = browser.div(class: /^instructionPopup__description$/)
      if additional_div.ul.present? && additional_div.ul.length > 0
        CSV.open("result/description_additional_#{TIME_NOW}.csv", "ab") do |csv|
          additional_div.ul.each_with_index do |li, i|
            if li.label(for: 'toggleInstructionItem-'+i.to_s).present?
              li.label(for: 'toggleInstructionItem-'+i.to_s).click
              sleep(2)
              csv << [index + Time.now.strftime("%s").to_i, el[:id], el[:title], li.h2.text + ':' + li.div(class: /^instructionPopup__itemContent$/).text.gsub('\n', ' '), Time.now.strftime("%Y-%d-%m %H:%M:%S")]
            end
          end
        end
      end
      sleep(rand(0..3))
    end
  end
end

# CSV.open("result/main_category.csv", "w") do |csv|
#   csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
#   csv << %w(id title url updated_at)
# end
#
# CSV.open("result/description_short_#{TIME_NOW}.csv", "w") do |csv|
#   csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
#   csv << %w(id product_id product_title params updated_at)
# end
#
# CSV.open("result/description_additional_#{TIME_NOW}.csv", "w") do |csv|
#   csv << [Time.now.strftime("%Y-%d-%m %H:%M:%S")]
#   csv << %w(id product_id product_title additional_params updated_at)
# end

result = main_categories
# get_details(result)