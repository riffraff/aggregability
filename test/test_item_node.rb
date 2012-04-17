# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'
require 'nokogiri'

class TestItemNode < Test::Unit::TestCase

  def item_node?(extractor, node)
      nodes = extractor.children_item_nodes(node)
      if nodes.size < 1
        return false
      elsif nodes.size > 5
        return false
      end
      true
  end

  def assert_item_node xml
    node = Nokogiri.parse(xml)
    e = Aggregability::Extractor.new
    msg = "not node:\n"
    msg += xml if $DEBUG
    assert item_node?(e,node), msg
  end

  def assert_not_item_node xml
    node = Nokogiri.parse(xml)
    e = Aggregability::Extractor.new
    msg = "node, expected not:\n"
    msg += xml if $DEBUG
    assert !item_node?(e, node), msg
  end

  Dir[File.join(File.dirname(__FILE__), '..', 'test','data', 'entry_ok', '*.html')].each do |data|
    define_method "test_#{data.gsub(/\.html/,'')}_ok" do
      assert_item_node(File.read(data))
    end
  end

  Dir[File.join(File.dirname(__FILE__), '..', 'test','data', 'entry_no', '*.html')].each do |data|
    define_method "test_#{data.gsub(/\.html/,'')}_ok" do
      assert_not_item_node(File.read(data))
    end
  end

  def test_closest_common_ancestor_for_most_nested
    node = Nokogiri.parse(<<-XML)
      <div id="body">
        <div class="title" id="dad">
          <span class="score" id="daughter">10</span>
          <a id="son"> link </a>
        </div>
      </div>
    XML

    e = Aggregability::Extractor.new
    nodes = e.children_item_nodes(node)
    assert_equal 2, nodes.size
    ns = e.closest_common_ancestor_for_most(nodes)
    assert_equal 'dad', ns['id']
  end

  def test_remove_nested_nodes

    nodes = Nokogiri.parse(<<-XML).search('*')
      <xml id="0">
        <div id="1">
          <div id="3">
            <div id="4">
            </div>
          </div>
        </div>
        <div id="2">
        </div>
      </xml>
    XML

    assert_equal 5, nodes.size
    e = Aggregability::Extractor.new
    nodes = e.remove_nested_nodes(nodes)
    assert_equal 1, nodes.size
  end

  def test_closest_common_ancestor_for_most_siblings
    node = Nokogiri.parse(<<-XML)
      <div id="granpa">
        <div id="dad">
          <div class="title" id="son">
            <a id="granddaughter"> link </a>
          </div>
          <span class="score" id="daughter">10</span>
        </div>
        <div id="dad">
          <div class="title" id="son">
            <a id="granddaughter"> link </a>
          </div>
          <span class="score" id="daughter">10</span>
        </div>
      </div>
    XML

    e = Aggregability::Extractor.new
    nodes = e.children_item_nodes(node)
    assert_equal 4, nodes.size
    ns = e.closest_common_ancestor_for_most(nodes)
    assert_equal 'granpa', ns['id']
  end

  def test_closest_common_ancestor_for_most_mixed
    node = Nokogiri.parse(<<-XML)
      <div id="ignorable">
        <div id="dad">
          <div class="title" id="son">
            <span class="grandson" id="daughter">10</span>
          </div>
          <span class="comments" id="daughter">10</span>
        </div>
      </div>
    XML

    e = Aggregability::Extractor.new
    nodes = e.children_item_nodes(node)
    ns = e.closest_common_ancestor_for_most(nodes)
    assert_equal 'dad', ns['id']
  end
end
