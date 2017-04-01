# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/systemd/core/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-systemd-core"
  spec.version       = Capistrano::Systemd::Core::VERSION
  spec.authors       = ["Alexander Simonov"]
  spec.email         = ["alex@simonov.me"]

  spec.summary       = %q{Capistrano SystemD core module}
  spec.description   = %q{Capistrano SystemD core module}
  spec.homepage      = "https://github.com/amoniacou/capistrano-systemd-core"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.3"
  spec.add_dependency "capistrano-bundler"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-kitchen", "~> 1.5.0"
end
