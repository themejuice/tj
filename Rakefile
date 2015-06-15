require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  require "ronn"

  ENV["RONN_MANUAL"] = "Theme Juice Manual"
  ENV["RONN_LAYOUT"] = "docs/templates/layout.html"
  ENV["RONN_STYLE"]  = "./docs/templates"

  desc "Build the manual"
  namespace :man do

    directory "lib/theme-juice/man"
    directory "docs/build"

    sources = Dir["man/*.ronn"].map{ |f| File.basename(f, ".ronn") }
    sources.map do |basename|
      ronn = "man/#{basename}.ronn"
      roff = "lib/theme-juice/man/#{basename}"
      html = case basename
             when "tj" then "index"
             else basename.gsub("tj-", "")
             end
      page = "docs/build/#{html}.html"

      file roff => ["lib/theme-juice/man", ronn] do
        sh "#{Gem.ruby} -S ronn --roff --pipe #{ronn} > #{roff}"
      end

      file roff => ["docs/build", ronn] do
        sh "#{Gem.ruby} -S ronn -w5 --style toc,main --pipe #{ronn} > #{page}"
      end

      file "#{roff}.txt" => roff do
        sh "groff -Wall -mtty-char -mandoc -Tascii #{roff} | col -b > #{roff}.txt"
      end

      task :build => "#{roff}.txt"
    end

    task :clean do
      rm_rf "lib/theme-juice/man"
      rm_rf "docs/build"
    end

    task :grunt do
      sh "grunt build --gruntfile docs/Gruntfile.coffee --quiet"
    end

    task :deploy do
      cd "docs/build"
      sh %Q{git checkout gh-pages}
      sh %Q{git pull}
      sh %Q{git rm -r .}
      sh %Q{git add --all}
      sh %Q{git commit -m "build for v#{ThemeJuice::VERSION} at #{Time.now.getutc}"}
      sh %Q{git push origin gh-pages}
      sh %Q{git symbolic-ref HEAD refs/heads/master}
      sh %Q{git reset --mixed}
    end
  end

  task :man => ["man:clean", "man:grunt", "man:build"]
rescue LoadError
  namespace :man do
    task(:build) { warn "Install the ronn gem to build the help pages" }
  end
end
