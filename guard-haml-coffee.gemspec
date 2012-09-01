# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guard/haml-coffee/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ouvrages"]
  gem.email         = ["contact@ouvrages-web.fr"]
  gem.description   = %q{Compiles HamlCoffee templates to javascript}
  gem.summary       = %q{Guard gem for HamlCoffee}
  gem.homepage      = "https://github.com/ouvrages/guard-haml-coffee"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "guard-haml-coffee"
  gem.require_paths = ["lib"]
  gem.version       = Guard::Haml::Coffee::VERSION

  gem.add_dependency('guard')
  gem.add_dependency('execjs')
  gem.add_dependency('coffee-script')
end
