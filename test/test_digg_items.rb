# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'

#notice that digg is evil and will load 3 ad items via js
class TestDiggItems < Test::Unit::TestCase
  def check fd
      e = Aggregability::Extractor.new 'http://digg.com'
      items = e.parse_io(fd)
      assert_equal 15, items.size
      first = items.first
      assert_equal "No, This Is Not a Housing Recovery", first.title
      assert_equal "http://digg.com/newsbar/topnews/no_this_is_not_a_housing_recovery", first.url
      assert_equal 50, first.score
      assert_equal 3, first.comments_count

      butlast =  items[-2]
      assert_equal "While AT&T, FCC behave like petulant schoolchildren, 1900 people suffer job losses", butlast.title
      assert_equal "http://digg.com/newsbar/topnews/while_at_t_fcc_behave_like_petulant_schoolchildren_1900_people_suffer_job_losses", butlast.url
      assert_equal 75, butlast.score
      assert_equal 9, butlast.comments_count
  end

  def test_find_items_digg
    open 'test/data/digg.html' do |fd|
      check fd
    end
  end
end

