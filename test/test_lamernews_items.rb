# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TC_lamernews_items < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new
      items = e.parse_io(fd)
      assert_equal 30, items.size
      first = items.first
      assert_equal "Android Ice Cream Sandwich: why native code support sucks", first.title
      assert_equal "http://www.moodstocks.com/2012/03/20/ice-cream-sandwich-why-native-code-support-sucks/", first.url
      assert_equal 6, first.score # 6+0
      assert_equal 0, first.comments_count

      butlast =  items[-2]
      assert_equal "Don’t Call Yourself A Programmer, And Other Career Advice", butlast.title
      assert_equal "http://www.kalzumeus.com/2011/10/28/dont-call-yourself-a-programmer/", butlast.url
      assert_equal 19, butlast.score
      assert_equal 1, butlast.comments_count
  end

  def test_find_items_lamernews
    open 'test/data/lamernews.html' do |fd|
      check fd
    end
  end
end
