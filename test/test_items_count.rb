# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TestItemsCounty < Test::Unit::TestCase
  def check fn, count
    open fn do |fd|
      items = Aggregability::Extractor.new.parse_io(fd)
      assert_equal count, items.size
    end
  end
  def test_items_count_mini_reddit_1
    check 'test/data/mini_reddit_1.html', 25
  end

  def test_items_count_reddit
    check 'test/data/reddit.html', 25
  end

  def test_items_count_mini_newsyc 
    check 'test/data/mini_news.ycombinator.html', 30
  end

  def test_items_count_newsyc 
    check 'test/data/news.ycombinator.html', 30
  end

  def test_items_count_digg 
    check 'test/data/digg.html', 15 # 18 if considering sponsored by audible, but those are loaded via js
  end

  def test_items_count_hubski
    check 'test/data/hubski.html', 33
  end

  def test_items_count_forlue
    check 'test/data/forlue.html', 30
  end

  def test_items_count_hackful
    check 'test/data/hackful.html', 20
  end

  def test_items_count_inbound
    check 'test/data/inbound.org.html', 25
  end
end
