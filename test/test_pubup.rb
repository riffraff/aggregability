# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

class TestPubup < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new
      items = e.parse_io(fd)
      assert_equal 10, items.size
      first = items.first
      assert_equal "Plant Pathogen Pseudomonas syringae pv. tomato Under Strong Selection to Evade Tomato Immunity", 
                   first.title
      assert_equal "/story.php?title=plant-pathogen-pseudomonas-syringae-pv-tomato-under-strong-selection-to-evade-tomato-immunity", first.url
      assert_equal 13, first.score # 6+0
      assert_equal 0, first.comments_count

      butlast =  items[-2]
      assert_equal "Moore's Law reaches the single atom limit", butlast.title
      assert_equal "/story.php?title=moores-law-reaches-the-single-atom-limit", butlast.url
      assert_equal 16, butlast.score
      assert_equal 0, butlast.comments_count
  end

  def test_find_items
    open 'test/data/pubup.html' do |fd|
      check fd
    end
  end

  def test_find_body
    str = File.read 'test/data/pubup.html'
    e = Aggregability::Extractor.new
    xml = Nokogiri.parse(str)
    b = e.find_content xml
    assert_equal  'div', b.name
    assert_equal  'leftcol', b['id']
  end
end
