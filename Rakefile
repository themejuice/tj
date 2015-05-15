lib = File.expand_path "../lib/", __FILE__
$:.unshift lib unless $:.include? lib

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "theme-juice/version"

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
  t.rspec_opts = "--color"
end

desc "Build gem"
task :build do
  sh "gem build theme-juice.gemspec"
end

desc "Install gem"
task :install do
  sh "gem install pkg/theme-juice-#{ThemeJuice::VERSION}.gem"
end

desc "Release gem"
task :push do
  sh "gem push pkg/theme-juice-#{ThemeJuice::VERSION}.gem"
end

task :default => [:spec]
