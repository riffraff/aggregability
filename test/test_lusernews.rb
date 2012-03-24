# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

#notice that metafilter is evil and will load 3 ad items via js
class TestLusernews < Test::Unit::TestCase

  def test_find_body_lusernews
    str = File.read 'test/data/lusernews.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'div', b.name
    assert_equal  'newslist', b['id']
  end

  def check fd
      e = Aggregability::Extractor.new nil, 'http://lusernews.com'
      items = e.parse_io(fd)
      assert_equal 30, items.size
      first = items.first
      assert_equal "Cache them if you can", first.title
      assert_equal "http://www.stevesouders.com/blog/2012/03/22/cache-them-if-you-can/", first.url
      assert_equal 1, first.score
      assert_equal 0, first.comments_count

      butlast =  items[-2]
      assert_equal "shelljs - Portable Unix shell commands for Node.js", butlast.title
      assert_equal "https://github.com/arturadib/shelljs", 
                   butlast.url
      assert_equal 1, butlast.score
      assert_equal 9, butlast.comments_count
  end

  def test_find_items_lusernews
    open 'test/data/lusernews.html' do |fd|
      check fd
    end
  end
end


