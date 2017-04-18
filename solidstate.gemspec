# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "solidstate"
  s.version     = '0.3.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tomás Pollak']
  s.email       = ['tomas@forkhq.com']
  s.homepage    = "https://github.com/tomas/solidstate"
  s.summary     = "Minuscule state machine."
  s.description = "Minuscule state machine."

  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", '~> 3.0', '>= 3.0.0'
  s.add_development_dependency "activerecord" #, ">= 4.0.0"
  s.add_development_dependency "sqlite3" #, ">= 4.0.0"
  s.add_development_dependency "mongo_mapper" #, ">= 4.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
