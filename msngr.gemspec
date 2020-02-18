lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "msngr/version"

Gem::Specification.new do |spec|
  spec.name = "msngr"
  spec.version = Msngr::VERSION
  spec.authors = ["Michael van Rooijen"]
  spec.email = ["michael@vanrooijen.io"]
  spec.description = "A light-weight Ruby library for multi-threaded Ruby applications that allows threads to share a single service connection for more efficient messaging."
  spec.summary = spec.description
  spec.homepage = "https://github.com/mrrooijen/msngr/"
  spec.license = "MIT"
  spec.files = Dir["./lib/**/*.rb"] + Dir["./spec/**/*.rb"]
  spec.test_files = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.4.2"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "pry", "~> 0.10.1"
  spec.add_development_dependency "simplecov", "~> 0.9.1"
  spec.add_development_dependency "yard", "~> 0.9.20.0"
  spec.add_development_dependency "redis", "~> 3.2.0"
  spec.add_development_dependency "hiredis", "~> 0.5.2"
  spec.add_development_dependency "parallel", "~> 1.3.3"
end
