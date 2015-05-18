# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|

  s.name        = "pushpop-mixpanel"
  s.version     = '0.1.1'
  s.authors     = ["Joe Wegner"]
  s.email       = "joe@keen.io"
  s.homepage    = "https://github.com/pushpop-project/pushpop-mixpanel"
  s.summary     = "Pushpop Mixpanel plugin for querying and recording events"

  s.add_dependency "pushpop"
  s.add_dependency "mixpanel-ruby", '~>2.1.0'
  s.add_dependency "mixpanel_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

