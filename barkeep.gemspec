# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barkeep/version'

Gem::Specification.new do |spec|
  
  spec.name          = "barkeep"
  spec.version       = Barkeep::VERSION
  spec.authors       = ["PatientsLikeMe"]
  spec.email         = ["open_source@patientslikeme.com"]
  spec.description   = "an extensible developer's status bar to track your current deployed commit & more"
  spec.summary       = "an extensible developer's status bar to track your current deployed commit & more"
  spec.homepage      = "https://github.com/patientslikeme/barkeep"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "grit"
  spec.add_runtime_dependency     "json"
  spec.add_development_dependency "mocha", ">= 0.9.12"
  spec.add_development_dependency "shoulda"
  spec.add_development_dependency "rcov"
  spec.add_development_dependency "rake"
end
