# encoding: UTF-8

lib = File.expand_path "../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "theme-juice/version"

Gem::Specification.new do |s|
  s.name           = "theme-juice"
  s.version        = ::ThemeJuice::VERSION
  s.authors        = ["Ezekiel Gabrielse"]
  s.email          = ["ezekg@yahoo.com"]
  s.description    = %q{tj helps you create new local WordPress development sites, manage existing sites, and deploy them, all from the command line.}
  s.summary        = %q{WordPress development made easy}
  s.homepage       = "http://themejuice.it"

  s.licenses       = "GPLv2"

  s.files          = Dir.glob "lib/**/*.*"
  s.files         += Dir.glob "lib/theme-juice/man/**/*"
  s.files         += ["README.md"]
  s.test_files     = s.files.grep %r{^(test|spec|features)/}
  s.executables    = ["tj"]
  s.require_paths  = ["lib"]

  s.required_ruby_version = ">= 1.9.3"

  # TODO: Remove after initial 1.0 release
  s.post_install_message = %Q{#{"#"*80}
                                 Hello there!

 There have been a few changes since the last time you updated, so please head
   over to https://github.com/ezekg/theme-juice-cli and check out the 0.27.0
                 release to review everything that's changed.

                        Thanks for using Theme Juice!
#{"#"*80}}

  s.add_runtime_dependency "thor",                     "~> 0.19.0"
  s.add_runtime_dependency "faker",                    "~> 1.4.0"
  s.add_runtime_dependency "os",                       "~> 0.9.0"
  s.add_runtime_dependency "capistrano",               "~> 3.4.0"
  s.add_runtime_dependency "net-ssh",                  "~> 2.9.0"
  s.add_runtime_dependency "capistrano-slackify",      "~> 2.6.0"
  s.add_runtime_dependency "capistrano-rsync-bladrak", "~> 1.3.8"

  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "rake",    "~> 10.4"
end
