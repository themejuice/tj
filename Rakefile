require_relative "lib/theme-juice/version"

task :build do
  sh "gem build theme-juice.gemspec"
  sh "sudo gem install theme-juice-#{ThemeJuice::VERSION}.gem"
end

task :release do
  sh "gem push theme-juice-#{ThemeJuice::VERSION}.gem"
end
