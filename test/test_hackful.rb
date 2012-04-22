# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

#notice that metafilter is evil and will load 3 ad items via js
class TestHackful < Test::Unit::TestCase

  HTML = 'test/data/hackful.eu.html'
  def test_find_body_hackful
    str = File.read HTML
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    node = e.find_content xml
    assert_equal  'div', node.name
    assert_equal  'body', node['class']
  end

  def check fd
      e = Aggregability::Extractor.new 'http://hackful.eu'
      items = e.parse_io(fd)
      assert_equal 20, items.size
      first = items.first
      assert_equal "Show Hackful: Facebook Profile Scanner", first.title
      assert_equal "http://checksocial.net", first.url
      assert_equal 3, first.score
      assert_equal 0, first.comments_count

      butlast =  items[-2]
      assert_equal "BusyFlow Launches Publicly At London Web Summit", butlast.title
      assert_equal "http://www.arcticstartup.com/2012/03/19/busyflow-launches-publicly-at-london-web-summit", 
                   butlast.url
      assert_equal 7, butlast.score
      assert_equal 0, butlast.comments_count
  end

  def test_find_items_hackful
    open HTML do |fd|
      check fd
    end
  end
end


