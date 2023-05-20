  require 'nokogiri'
  require 'open-uri'
  require 'watir'
  require 'json'
	require 'pry'
	require "google_drive"
	require "googleauth"

  class Parser
		attr_accessor :browser, :cities

	  def initialize
	  	@browser = Watir::Browser.new 
	  	@cities = []
	  	connect
	  end
 
 	  def connect
 	  	browser.goto('https://move-o-naut.com/halteverbot_umzug_alle_orte.html#Halteverbote_in_Orten_mit_dem_Buchstaben_T')
 	  	Watir::Wait.until { browser.div(class: "content") }

 	  	links_page = Nokogiri::HTML.parse(browser.div(class: "content").html)
 	  	links 		 = links_page.css("a:contains('Halteverbotszone')").map {|link| link.attr("href")}

 	 	  links.each do |link|
 	 	  	p link
 	 	  	browser.goto(link)
 	 	  	Watir::Wait.until { browser.div(id: "HVZ_PREIS").present? || browser.p(text: /The requested URL was not found on this server/).present? }

 	 			next if browser.p(text: /The requested URL was not found on this server/).present?

 	 			cells = browser.div(id: "HVZ_PREIS").divs.map(&:text)
 	 			prices = { cells[0].delete(":") => cells[1], cells[2].delete(":") => cells[3], cells[5].delete(":") => cells[6] }

 	 			cities.push(
 	 				city_name: browser.text_field(id: "HVZ_ORT").value,
 	 				halteverbot: prices["Halteverbot"],
 	 				genehmigung: prices["Genehmigung"],
 	 				gesamt:      prices["Gesamt"] 
 	 			)

 	 			 File.open("cities.json","w") do |data|
      		data.write(JSON.pretty_generate(cities))
    		end
 	 	  end
 	 	end
	end

Parser.new