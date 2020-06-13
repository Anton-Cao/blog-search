# typed: strict

require 'httparty'
require 'nokogiri'
require 'sorbet-runtime'

require_relative 'helper'

module BlogChecker
  extend T::Sig

  BlogBlacklist = T.let(['github.com', '.gov'], T::Array[String])
  BlogTLDS = T.let(['.me', '.blog'], T::Array[String])
  BlogTLDBonus = 2
  BlogKeywords = T.let(['I', 'I\'ve', 'I\'m', 'blogging', 'resume', 'personal', 'projects'].to_set, T::Set[String])
  ThresholdScore = 4

  # Applies heuristics to determine if a website is a personal blog
  sig{params(blog_uri:String).returns(T::Boolean)}
  def self.is_blog?(blog_uri)
      uri = URI.parse(blog_uri)

      BlogBlacklist.each { |blacklisted| return false if uri.host&.include? blacklisted }

      score = 0
      score += BlogTLDBonus if BlogTLDS.any? { |tld| uri.host&.end_with?(tld) }

      unless (html = (Helper::get_html "#{uri.scheme}://#{uri.host}")).nil?
        html.xpath('//p').each do |p|
          p.content.split(/\b/).each do |word|
            score += 1 if BlogKeywords.include? word
          end
        end
      end

      score >= ThresholdScore
  end
end
