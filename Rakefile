require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative "lib/theme-juice/version"

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
  t.rspec_opts = "--color"
end

task :build do
  sh "gem build theme-juice.gemspec"
  sh "sudo gem install theme-juice-#{ThemeJuice::VERSION}.gem"
end

task :release do
  sh "gem push theme-juice-#{ThemeJuice::VERSION}.gem"
end

task :default => [:spec]
