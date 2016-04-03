# encoding: UTF-8

namespace :rsync do

  after :stage, :precompile do
    run_locally do
      Dir.chdir fetch(:rsync_stage) do
        fetch(:rsync_install, []).each { |t| execute t }
      end
    end
  end

  after :precompile, :ignore do
    run_locally do
      fetch(:rsync_ignore, []).each { |f|
        execute :rm, Pathname.new(fetch(:rsync_stage)).join(f) }
    end
  end

  after "deploy:started", :pre_scripts do
    on roles(:app) do
      within fetch(:deploy_to) do
        fetch(:rsync_pre_scripts, []).each { |t| execute t }
      end
    end
  end

  after "deploy:finished", :post_scripts do
    on roles(:app) do
      within fetch(:deploy_to) do
        fetch(:rsync_post_scripts, []).each { |t| execute t }
      end
    end
  end

  after "deploy:finished", :clean do
    run_locally do
      return if Pathname.new(fetch(:rsync_stage)).absolute?

      if fetch(:clean_tmp, true)
        execute :rm, "-rf", fetch(:rsync_stage)
      end
    end
  end

  namespace :prepare do

    before "deploy:check:directories", :directories do
      on roles(:app) do
        within fetch(:deploy_to) do
          execute :mkdir, "-p", fetch(:rsync_cache)
        end
      end
    end

    before "deploy:check:linked_files", :files do
      on roles(:app) do
        fetch(:linked_files).each { |f|
          execute :touch, shared_path.join(f) }
      end
    end

    before "deploy:check:linked_dirs", :dirs do
      on roles(:app) do
        fetch(:linked_dirs).each { |f|
          execute :mkdir, "-p", shared_path.join(f) }
      end
    end
  end
end
