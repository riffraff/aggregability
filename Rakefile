# -*- encoding : utf-8 -*-
require "bundler/gem_tasks"
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/test*.rb']
end
task :default => :test

desc "generate test/data/domain.{html,yml} files from a url http://domain"
task :generate_expected_result, :url  do |t, args|
  require 'open-uri'
  url = args[:url]
  outfn = File.join('test', 'data', url.gsub("http://",'').gsub("www.",'').gsub("/","_")+".html")
  fail('file exists') if File.exist?(outfn)
  open(url) do |inp|
    open(outfn, 'w+') do |out|
      out.write(inp.read)
    end
  end
  Rake::Task[:rebuild_expected_results_yaml].invoke(outfn)
end

desc "regenerate test/data/*.yml files describing the expected results for each site"
task :rebuild_expected_results_yaml, :filename  do |t, args|
  $:.unshift './lib'
  require 'yaml'
  # why force syck? cause bundler or rakefile force psych, which generates somewhat broken yaml
  # and !!null annotations for empty fields which are not being parsed back in tests
  YAML::ENGINE.yamler = 'psych'
  require 'aggregability'
  fileset = args[:filename] ? [args[:filename]] : Dir['./test/data/*.html']
  fileset.each do |fn|
    begin
      open(fn) do |fd|
        puts "Reading #{fn}"
        items = Aggregability::Extractor.new('http://'+File.basename(fn).gsub('.html', '')).parse_io(fd)
        yfn = fn.sub /html$/, 'yml'
        puts "Writing #{yfn}"
        open(yfn, 'w+') do |yfd|
          YAML.dump(items.map(&:to_hash), yfd)
        end
      end
    rescue
      puts $!
    end
    
  end

end

begin
  require 'ruby-prof/task'
  RubyProf::ProfileTask.new do |t|
    t.libs << 'lib' << 'test'
    t.test_files = FileList['tc_all.rb']
    t.output_dir = "profiling"
    t.printer = :graph_html
    t.min_percent = 2
  end
rescue LoadError
  puts "cannot load ruby-prof tasks (using jruby?)"
  puts $!
end
