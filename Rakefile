require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  require "ronn"

  namespace :man do
    directory "lib/theme-juice/man"

    sources = Dir["man/*.ronn"].map{|f| File.basename(f, ".ronn") }
    sources.map do |basename|
      ronn = "man/#{basename}.ronn"
      roff = "lib/theme-juice/man/#{basename}"

      file roff => ["lib/theme-juice/man", ronn] do
        sh "#{Gem.ruby} -S ronn --roff --pipe #{ronn} > #{roff}"
      end

      file "#{roff}.txt" => roff do
        sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
      end

      task :build_all_pages => "#{roff}.txt"
    end

    task :clean do
      leftovers = Dir["lib/theme-juice/man/*"].reject do |f|
        basename = File.basename(f).sub(/\.(txt|ronn)/, '')
        sources.include?(basename)
      end
      rm leftovers if leftovers.any?
    end

    desc "Build the man pages"
    task :build => ["man:clean", "man:build_all_pages"]

    desc "Remove all built man pages"
    task :clobber do
      rm_rf "lib/theme-juice/man"
    end

    task(:require) { }
  end

rescue LoadError
  namespace :man do
    task(:require) { abort "Install the ronn gem to be able to release!" }
    task(:build) { warn "Install the ronn gem to build the help pages" }
  end
end
