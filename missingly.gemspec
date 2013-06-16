# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'missingly/version'

Gem::Specification.new do |spec|
  spec.name          = "missingly"
  spec.version       = MethodMissingImproved::VERSION
  spec.authors       = ["Thijs de Vries"]
  spec.email         = ["moger777@gmail.com"]
  spec.description   = %q{A DSL for defining method missing methods}
  spec.summary       = %q{A DSL for defining method missing methods}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "rspec"
end
