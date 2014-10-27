# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tinder/version'

Gem::Specification.new do |spec|
  spec.name          = "tinder"
  spec.version       = Tinder::VERSION
  spec.authors       = ["Ezekiel Gabrielse"]
  spec.email         = ["ezekg@yahoo.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

require_relative 'lib/flint'

Gem::Specification.new do |spec|

  # Info
  spec.version = Flint::VERSION

  # Details
  spec.name = "tinder-cli"
  spec.rubyforge_project = "tinder-cli"
  spec.licenses = "MIT"
  spec.authors = ["Ezekiel Gabrielse"]
  spec.email = ["ezekg@yahoo.com"]
  spec.homepage = "https://github.com/ezekg/tinder-cli.git"

  # Description
  spec.summary = %q{A WordPress theme development framework.}
  spec.description = %q{A WordPress theme development framework.}

  # Library
  spec.files += Dir.glob("lib/**/*.*")

  # Other
  spec.files += ["LICENSE", "README.md"]

  # Executable
  spec.executables = ["tinder"]

  # Test
  spec.test_files += Dir.glob("tests/**/*.*")

  # Dependencies
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "compass", "~> 1.0"
  spec.add_dependency "sass", "~> 3.4"
end
