# encoding: UTF-8

lib = File.expand_path "../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "theme-juice/version"

Gem::Specification.new do |gem|
  gem.name           = "theme-juice"
  gem.version        = ::ThemeJuice::VERSION
  gem.authors        = ["Ezekiel Gabrielse"]
  gem.email          = ["ezekg@yahoo.com"]
  gem.description    = %q{Theme Juice is a WordPress development command line utility that allows you to scaffold out entire Vagrant development environments in seconds, manage dependencies and build tools, and even handle deployments.}
  gem.summary        = %q{Theme Juice - WordPress development made easy}
  gem.homepage       = "https://themejuice.it"

  gem.licenses       = "MIT"

  gem.files          = Dir.glob("lib/**/*.*")
  gem.files         += ["README.md"]
  gem.test_files     = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables    = ["tj"]
  gem.require_paths  = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_runtime_dependency "thor",  "~> 0.19"
  gem.add_runtime_dependency "faker", "~> 1.4"
  gem.add_runtime_dependency "os",    "~> 0.9"

  gem.add_development_dependency "bundler", "~> 1.0"
  gem.add_development_dependency "rake",    "~> 10.4"
  gem.add_development_dependency "rspec",   "~> 3.2"
  gem.add_development_dependency "fakefs",  "~> 0.6"
  gem.add_development_dependency "ronn",    "~> 0.7"
end
