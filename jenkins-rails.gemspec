# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jenkins-rails/version'

Gem::Specification.new do |gem|
  gem.name          = "jenkins-rails"
  gem.version       = Jenkins::VERSION
  gem.authors       = ["Anh Nguyen"]
  gem.email         = ["anhkind@gmail.com"]
  gem.description   = %q{Jenkins integration for Rails}
  gem.summary       = %q{Jenkins integration for Rails}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end