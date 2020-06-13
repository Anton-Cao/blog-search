# typed: strict

require 'httparty'
require 'nokogiri'
require 'sorbet-runtime'

module Helper
  extend T::Sig

  sig{params(url: String).returns(T.nilable(Nokogiri::HTML::Document))}
  def self.get_html(url)
    begin
      response = HTTParty.get url
      if response.headers['content-type'].include? 'text/html'
        html = Nokogiri::HTML(response.parsed_response)
        return html
      end
      nil
    rescue
      nil
    end
  end
end
