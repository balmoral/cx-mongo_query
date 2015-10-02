# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cx/mongo_query/version'

Gem::Specification.new do |spec|
  spec.name          = 'cx-mongo_query'
  spec.version       = CX::Mongo::Query::VERSION
  spec.date          = '2015-10-02'
  spec.summary       = 'Shorthand helpers for constructing readable Mongo query args'
  spec.authors       = ['Colin Gunn']
  spec.email         = 'colgunn@icloud.com'
  spec.homepage      = 'http://rubygemspec.org/gems/cx-mongo_query' # TODO: push to rubygems ??
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
end
