namespace :wp do

  #
  # Setup WordPress
  #
  namespace :setup do

    desc "Set permissions"
    task :permissions do
      on roles :app do
        execute :chmod, "644", shared_path.join(".env.#{fetch(:stage)}")
        execute :chmod, "644", release_path.join("wp-config.php")
        execute :chmod, "644", release_path.join(".htaccess")
        execute :chmod, "-R 777", shared_path.join("app/uploads")
      end
    end

    desc "Create shared files and folders"
    task :files do
      on roles :app do

        # Create shared directories
        execute :mkdir, "-p", shared_path.join("app/uploads")

        # Create empty .env
        execute :touch, shared_path.join(".env.#{fetch(:stage)}")

        # # Upload shared dev_files
        # upload! "wp-config.php", shared_path.join("wp-config.php")
        # upload! ".htaccess", shared_path.join(".htaccess")
      end
    end
  end

  #
  # Cleanup WordPress
  #
  namespace :cleanup do

    desc "Remove development files"
    task :files do
      on roles :app do

        # Remove development files
        dev_files = [
          "app/themes/theme-juice/src/",
          "config/",
          "lib/",
          ".env.sample",
          ".gitignore",
          # ".tj.yml",
          "Capfile",
          "composer.json",
          "composer.lock",
          "config.rb",
          "Gemfile",
          "Gemfile.lock",
          # "Gruntfile.js",
          "Guardfile",
          "README.md",
          "tj.yml",
          "wp-cli.local.yml",
        ].each do |f|
          execute :rm, "-rf", release_path.join(f)
        end

        # Remove robots.txt on production
        execute :rm, release_path.join("robots.txt") if fetch(:stage) == :production
      end
    end
  end
end
