#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    field :id do
      url[/key=(\w+)/, 1]
    end

    # Move the final name-part to the front
    field :name do
      parts = display_name.split(/\s+/)
      parts.unshift(parts.pop).join(' ')
    end

    field :party do
      tds[1].text.tidy
    end

    private

    def display_name
      tds[0].css('a').text.tidy
    end

    def tds
      noko.css('td')
    end

    def url
      tds[0].css('a/@href').text
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      noko.css('#story table').xpath('.//tr[td[2]]').map { |mp| fragment(mp => Member).to_h }
    end
  end
end

url = 'https://www.lachambre.be/kvvcr/showpage.cfm?section=/depute&language=fr&cfm=cvlist54.cfm?legis=55&today=y'
puts EveryPoliticianScraper::ScraperData.new(url).csv
