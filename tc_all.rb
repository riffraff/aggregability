require 'yaml'
puts YAML::ENGINE.yamler
YAML::ENGINE.yamler = 'psych'
Dir['test/*.rb'].each do |fn| load fn end
