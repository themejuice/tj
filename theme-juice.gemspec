# encoding: UTF-8

require_relative "lib/theme-juice"

Gem::Specification.new do |gem|
  gem.name           = "theme-juice"
  gem.version        = ::ThemeJuice::VERSION
  gem.authors        = ["Ezekiel Gabrielse"]
  gem.email          = ["ezekg@yahoo.com"]
  gem.description    = %q{Theme Juice is a WordPress development command line utility that allows you to scaffold out entire Vagrant development environments in seconds, manage dependencies and build tools, and even handle deployments.}
  gem.summary        = %q{Theme Juice - WordPress development made easy}
  gem.homepage       = "https://themejuice.it"

  gem.licenses       = "GNU"

  gem.files          = Dir.glob("lib/**/*.*")
  gem.files         += ["README.md"]
  gem.test_files     = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables    = ["tj"]
  gem.require_paths  = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"
  gem.add_dependency "thor",  "~> 0.19"
  gem.add_dependency "faker", "~> 1.4"
  gem.add_dependency "os",    "~> 0.9"
end
