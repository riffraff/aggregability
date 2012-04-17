# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "aggregability/version"

Gem::Specification.new do |s|
  s.name        = "aggregability"
  s.version     = Aggregability::VERSION
  s.authors     = ["Gabriele Renzi"]
  s.email       = ["rff.rff+aggregability@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{scrape aggregator sites like reddit, hackernews, digg}
  s.description = %q{scrape aggregator sites like reddit, hackernews, digg}

  s.rubyforge_project = "aggregability"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.bindir = 'bin'
  

  # specify any dependencies here; for example:
  s.add_development_dependency "rake", '~> 0.9.2.2'
  s.add_runtime_dependency "nokogiri", '~> 1.5.0'
end
