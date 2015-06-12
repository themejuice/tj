# encoding: UTF-8

lib = File.expand_path "../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "theme-juice/version"

Gem::Specification.new do |gem|
  gem.name           = "theme-juice"
  gem.version        = ::ThemeJuice::VERSION
  gem.authors        = ["Ezekiel Gabrielse"]
  gem.email          = ["ezekg@yahoo.com"]
  gem.description    = %q{Theme Juice is a WordPress development command line utility that allows you to scaffold out an entire Vagrant development environment in seconds (using an Apache fork of VVV called VVV-Apache as the VM). It also helps you manage dependencies and build tools, and can even handle your deployments.}
  gem.summary        = %q{Theme Juice - WordPress development made easy}
  gem.homepage       = "https://themejuice.it"

  gem.licenses       = "GNU"

  gem.files          = Dir.glob "lib/**/*.*"
  gem.files         += Dir.glob "lib/theme-juice/man/**/*"
  gem.files         += ["README.md"]
  gem.test_files     = gem.files.grep %r{^(test|spec|features)/}
  gem.executables    = ["tj"]
  gem.require_paths  = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_runtime_dependency "thor",       "~> 0.19"
  gem.add_runtime_dependency "faker",      "~> 1.4"
  gem.add_runtime_dependency "os",         "~> 0.9"
  gem.add_runtime_dependency "capistrano", "~> 3.3"

  gem.add_development_dependency "bundler", "~> 1.0"
  gem.add_development_dependency "rake",    "~> 10.4"
end
