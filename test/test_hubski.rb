# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TC_hubski_items < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new
      items = e.parse_io(fd)
      # not 30, as one element is non standard 
      assert_equal 33, items.size
      first = items.first
      assert_equal "Hubski visits Ground Zero and the NYPD", first.title
      assert_equal "/pub?id=23314", first.url
      #assert_equal 1769, first.score
      #assert_equal 4, first.comments_count img src=combubble??

      butlast =  items[-2]
      assert_equal "In the Time of the Dark Souls", butlast.title
      assert_equal "http://inthetimeofthedarksouls.wordpress.com/", butlast.url
      #assert_equal 232, butlast.score
      #assert_equal 22, butlast.comments_count actually 0
  end

  def test_find_items_hubski
    open 'test/data/hubski.com.html' do |fd|
      check fd
    end
  end
end
