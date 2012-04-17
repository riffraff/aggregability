# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'
require 'yaml'

YAML::ENGINE.yamler = 'psych'
class TestAllItems < Test::Unit::TestCase
  Dir[File.join(File.dirname(__FILE__), '..', 'test','data', '*.html')].each do |fn|
    expected = YAML.load_file(fn.sub(/html$/,'yml'))
    define_method "test_#{fn.gsub(/\.html/,'').gsub(/\W/,'_')}_ok" do
      assert_instance_of  Array, expected
      open fn do |fd|
      items = Aggregability::Extractor.new('http://example.com').parse_io(fd)
        #puts items.map(&:title)
        assert_equal expected.size, items.size
        items.zip(expected).each_with_index do |(item, exp), i|
          %w[title url scores score comments_count].each do |fld|
            assert_equal exp[fld.to_sym], 
                         item.send(fld), 
                         "not matching #{fld} for item #{i} (#{exp[:title]})"
          end
        end
      end
    end
  end
end
