# typed: strict

require 'pp'
require 'uri'
require 'httparty'
require 'nokogiri'
require 'sorbet-runtime'

require_relative 'models'
require_relative 'range_set'

module HNScraper
  extend T::Sig

  class HNApi
    extend T::Sig

    include HTTParty
    base_uri 'https://hacker-news.firebaseio.com/v0'

    sig{returns(Integer)}
    def maxitem()
      self.class.get("/maxitem.json").parsed_response
    end

    sig{params(item_id: Integer).returns(T::Hash[String, T.untyped])}
    def item(item_id)
      self.class.get("/item/#{item_id}.json").parsed_response
    end
  end

  SeenIdsFile = "seen_hn_ids"

  sig{params(count: Integer).void}
  def self.scrape(count)
    seen = RangeSet.new
    seen.load SeenIdsFile
    hn = HNApi.new
    max_item = hn.maxitem

    start_item = max_item - 100000
    end_item = start_item + count
    (start_item..end_item).each do |item_id|
      next if !seen.add(item_id)
      begin
        item = hn.item(item_id)
        hn_item = Models::HnItem.new(hn_id: item_id, score: item["score"], url: item["url"])
        hn_item.save()
      rescue => e
        puts "Rescued #{e}"
      end
    end

    seen.save SeenIdsFile
  end
end


# response = HTTParty.get("#{HN_API_ROOT}maxitem.json")
# max_item = response.parsed_response
# start_item = max_item - 100000
# end_item = start_item + 100
# (start_item..end_item).each do |item_id|
#   if HnItem.find_by(:hn_id => item_id) != nil
#     puts "skipping #{item_id}"
#   end
#   begin
#     response = HTTParty.get "#{HN_API_ROOT}item/#{item_id}.json"
#     item = response.parsed_response
#     hn_item = HnItem.new(hn_id: item_id, score: item["score"], url: item["url"])
#     hn_item.save()
#   rescue => e
#     puts "Rescued #{e}"
#   end
# end


# sig {params(url: String).returns(T::Boolean)}
# def is_blog?(url)
#   uri = URI.parse(url)
#   return true if uri.host.end_with?(*['.me', '.blog']) # TODO score contribution instead of direct success
#   BlogBlacklist.each { |blacklisted| return false if uri.host&.include? blacklisted }
#   response = HTTParty.get "#{uri.scheme}://#{uri.host}"
#   begin
#     if response.headers['content-type'].include? 'text/html'
#       html = Nokogiri::HTML(response.parsed_response)
#       score = 0
#       html.xpath('//p').each do |p|
#         p.content.split(/\b/).each do |word|
#           if BlogKeywords.include? word
#             score += 1
#           elsif NonBlogKeywords.include? word
#             score -= 1
#           end
#         end
#       end
#       return score >= 2
#     else
#       puts "#{uri} did not return HTML"
#     end
#   rescue => e
#     puts "Rescued #{e.inspect}"
#   end
#   false
# end

# sig {params(url: String).returns(T::Array[T.untyped])}
# def get_path_structure(url)
#   path_structure = Array.new
#   uri = URI.parse(url)
#   uri.path&.split('/')&.each do |part|
#     next if part == ''
#     if /\d+/ === part
#       path_structure.push :num
#     elsif ['blog', 'posts', 'post'].include? part
#       path_structure.push(part)
#       else
#       path_structure.push :str
#     end
#   end
#   path_structure
# end

# sig {params(url: String).returns(T::Array[T.untyped])}
# def find_posts(url)
#   # Assumptions:
#   #   - all posts can be reached via links from the base URL
#   #   - blog posts will have a similar path structure
#   uri = URI.parse(url)
#   root = "#{uri.scheme}://#{uri.host}"
#   visited = Set.new
#   queue = [root]
#   while cur_path = queue.shift
#     if !visited.include? cur_path
#       visited.add cur_path
#       response = HTTParty.get cur_path
#       if response.headers['content-type'].include? 'text/html'
#         html = Nokogiri::HTML(response.parsed_response)
#         html.xpath('//a').each do |a|
#           link = a['href']
#           if link.start_with? '/'
#             link = "#{root}#{link}"
#           end
#           if link.start_with? root
#             link_uri = URI.parse(link)
#             queue.push "#{link_uri.scheme}://#{link_uri.host}#{link_uri.path}"
#           end
#         end
#       end
#     end
#   end
#   post_path_structure = get_path_structure(url)
#   visited.select{ |path| get_path_structure(path) == post_path_structure }
# end


# HnItem.where('is_blog IS NULL').each do |item|
#   if item.url != nil && item.score != nil && item.score >= 2
#     item.is_blog = is_blog?(item.url) ? 1 : 0
#     puts "#{item.url} is blog? #{item.is_blog}"
#     item.save()
#   end
# end

# posts = find_posts("https://frenxi.com/life-in-quarantine/")
# puts posts

