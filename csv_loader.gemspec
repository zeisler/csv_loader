# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_loader/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_loader"
  spec.version       = CsvLoader::VERSION
  spec.authors       = ["Dustin Zeisler"]
  spec.email         = ["dustin@zive.me"]
  spec.summary       = %q{Load Csv files into ActiveRecord Models with simple query selection.}
  spec.description   = %q{Load Csv files into ActiveRecord Models with simple query selection. Queries like limit, where, find.}
  spec.homepage      = "https://github.com/zeisler/attr_permit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~>3.0"
  spec.add_development_dependency "active_mocker", "~>1.6"
end
