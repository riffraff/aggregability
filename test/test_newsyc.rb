# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TC_news_yc_items < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new 'http://news.ycombinator.com'
      items = e.parse_io(fd)
      # not 30, as one element is non standard 
      assert_equal 30, items.size
      first = items.first
      assert_equal "Poll: What's Your Favorite Programming Language?", first.title
      assert_equal "http://news.ycombinator.com/item?id=3746692", first.url
      assert_equal 1769, first.score
      assert_equal 458, first.comments_count

      butlast =  items[-2]
      assert_equal "agentzh's Nginx Tutorials", butlast.title
      assert_equal "http://agentzh.org/misc/nginx/agentzh-nginx-tutorials-enuk.html", butlast.url
      assert_equal 232, butlast.score
      assert_equal 22, butlast.comments_count
  end

  def test_find_items_mini_newsyc
    open 'test/data/mini_news.ycombinator.html' do |fd|
      check fd
    end
  end

  def test_find_items_newyc
    open 'test/data/news.ycombinator.com.html' do |fd|
      check fd
    end
  end
end
