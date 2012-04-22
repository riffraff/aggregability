# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TestILoveLeanItems < Test::Unit::TestCase

  def check fd
      e = Aggregability::Extractor.new 'http://ilovelean.com'
      items = e.parse_io(fd, nil)
      assert_equal 38, items.size
      first = items.first
      assert_equal "I am a lousy copywriter", first.title
      assert_equal "http://www.lettersofnote.com/2012/01/i-am-lousy-copywriter.html", first.url
      assert_equal nil, first.score # 6+0
      # haven't seen comments
      assert_equal 0, first.comments_count
  end

  def test_find_items_ilovelean
    open 'test/data/ilovelean.com.html' do |fd|
      check fd
    end
  end

  def test_find_body_ilovelean
    str = File.read 'test/data/ilovelean.com.html'
    str.force_encoding('iso-8859-1')
    e = Aggregability::Extractor.new 'http://ilovelean.com'
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'div', b.name
    assert_equal  'allstories', b['id']
  end
end
