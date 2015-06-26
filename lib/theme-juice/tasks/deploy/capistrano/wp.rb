# encoding: UTF-8

namespace :wp do

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

        execute :mkdir, "-p", shared_path.join("app/uploads")

        execute :touch, shared_path.join(".env.#{fetch(:stage)}")

        # upload! "wp-config.php", shared_path.join("wp-config.php")
        # upload! ".htaccess", shared_path.join(".htaccess")
      end
    end
  end

  namespace :cleanup do

    desc "Remove development files"
    task :files do
      on roles :app do

        dev_files = [].each do |f|
          execute :rm, "-rf", release_path.join(f)
        end

        execute :rm, release_path.join("robots.txt") if fetch(:stage) == :production
      end
    end
  end
end
