# -*- encoding : utf-8 -*-

require 'test/unit'
require 'aggregability'

class TC_reddit_items < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new
      items = e.parse_io(fd)
      assert_equal 25, items.size
      first = items.first
      assert_equal "My 7-year old's humour. I think he's got talent...", first.title
      assert_equal "http://imgur.com/W8pEP", first.url
      assert_equal [1135, 1136, 1137], first.scores
      assert_equal 58, first.comments_count

      butlast =  items[-2]
      assert_equal <<-TXT.strip, butlast.title
      From Roger Ebert's Facebook: "Oh, no! In a move to recoup their unwise investment in 3D, theaters discuss, and I quote, 'patrons will have a single price for both 2D and 3D films. 2D prices will increase and 3D prices will decrease.' In other words, punishing those who dislike 3D."
      TXT
      assert_equal "http://www.screentrademagazine.com/#/joe-paletta/4558914185", butlast.url
      assert_equal [2031, 2032, 2033], butlast.scores
      assert_equal 1373, butlast.comments_count
  end
  def test_find_body_mini_reddit_1
    open 'test/data/mini_reddit_1.html' do |fd|
      check fd
    end
  end

  def test_find_body_reddit
    open 'test/data/reddit.html' do |fd|
      check fd
    end
  end
end
