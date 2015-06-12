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

    task :pages do
      # verbose(false) {
      #   rm_rf "pages"
      #   push_url = `git remote show origin`.grep(/Push.*URL/).first[/git@.*/]
      #   sh "
      #     set -e
      #     git fetch -q origin
      #     rev=$(git rev-parse origin/gh-pages)
      #     git clone -q -b gh-pages . pages
      #     cd pages
      #     git reset --hard $rev
      #     rm -f ronn*.html index.html
      #     cp -rp ../man/ronn*.html ../man/index.txt ../man/index.html ./
      #     git add -u ronn*.html index.html index.txt
      #     git commit -m '#{ThemeJuice::VERSION}'
      #     git push #{push_url} gh-pages
      #   ", :verbose => false
      # }
    end
  end

  task :man => ["man:clean", "man:grunt", "man:build", "man:pages"]
rescue LoadError
  namespace :man do
    task(:build) { warn "Install the ronn gem to build the help pages" }
  end
end
