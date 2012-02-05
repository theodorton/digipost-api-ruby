# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "digipost-api/version"

Gem::Specification.new do |s|
  s.name        = "digipost-api"
  s.version     = Digipost::Api::VERSION
  s.authors     = ["Theodor Tonum"]
  s.email       = ["theodor@tonum.no"]
  s.homepage    = "http://github.com/theodorton/digipost-api-ruby"
  s.summary     = %q{Ruby API for sending messages through Digipost}
  s.description = %q{Simple Ruby API you can use to send messages through Digipost}

  s.rubyforge_project = "digipost-api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_dependency "httparty", "~>0.7"
  s.add_dependency "crack"
  s.add_dependency "rsa"
end
