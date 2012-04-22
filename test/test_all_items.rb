# -*- encoding : utf-8 -*-
require 'test/unit'
require 'aggregability'
require 'yaml'

YAML::ENGINE.yamler = 'psych'
class TestAllItems < Test::Unit::TestCase
  Dir[File.join(File.dirname(__FILE__), '..', 'test','data', '*.html')].each do |fn|
    begin
    expected = YAML.load_file(fn.sub(/html$/,'yml'))
    rescue 
      puts "no data file for #{fn}"
      next
    end
    define_method "test_#{fn.gsub(/\.html/,'').gsub(/\W/,'_')}_ok" do
      assert_instance_of  Array, expected
      open fn do |fd|
        items = Aggregability::Extractor.new('http://' + File.basename(fn).gsub('.html','')).parse_io(fd)
        items.zip(expected).each_with_index do |(item, exp), i|
          assert exp, "missing element at #{i}, actual #{item.inspect}"
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
