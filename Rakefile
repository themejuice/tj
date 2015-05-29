require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  require "ronn"

  desc "Build the manual"
  namespace :man do

    directory "lib/theme-juice/man"
    sources = Dir["man/*.ronn"].map{ |f| File.basename(f, ".ronn") }
    sources.map do |basename|
      ronn = "man/#{basename}.ronn"
      roff = "lib/theme-juice/man/#{basename}"

      file roff => ["lib/theme-juice/man", ronn] do
        sh "#{Gem.ruby} -S ronn --roff --manual 'Theme Juice Manual' --pipe #{ronn} > #{roff}"
      end

      file "#{roff}.txt" => roff do
        sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
      end

      task :build => "#{roff}.txt"
    end

    task :clean do
      rm_rf "lib/theme-juice/man"
    end
  end

  task :man => ["man:clean", "man:build"]
rescue LoadError
  namespace :man do
    task(:build) { warn "Install the ronn gem to build the help pages" }
  end
end
