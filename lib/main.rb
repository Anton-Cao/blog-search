# typed: strict

require 'sqlite3'
require 'active_record'
require 'sorbet-runtime'

require_relative 'hn_scraper'
require_relative 'blog_checker'

db = SQLite3::Database.open 'test.db'
db.execute %{
CREATE TABLE IF NOT EXISTS hn_items (
  hn_id INT,
  score INT,
  url TEXT,
  is_blog INT
);}

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'test.db'
)

#HNScraper::scrape(10)
puts BlogChecker::is_blog?("https://www.rubyguides.com/2018/10/any-all-none-one/")
