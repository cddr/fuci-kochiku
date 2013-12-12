# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fuci/kochiku/version'

Gem::Specification.new do |spec|
  spec.name          = "fuci-kochiku"
  spec.version       = Fuci::Kochiku::VERSION
  spec.authors       = ["Jen Page", "Joe Hughes", "Andy Chambers"]
  spec.email         = ["achambers.home@gmail.com"]
  spec.description   = %q{FUCK YOU CI: For Kochiku! :).}
  spec.summary       = %q{Run failures from your recent Kochiku builds locally.}
  spec.homepage      = "https://github.com/cddr/fuci-kochiku"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'fuci', '~> 0.4'
  spec.add_dependency 'httparty'
  spec.add_dependency 'libarchive'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "minitest-spec-expect", "~> 0.1"
  spec.add_development_dependency "mocha", "~> 0.14"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "fakeweb", ["~> 1.3"]
end
