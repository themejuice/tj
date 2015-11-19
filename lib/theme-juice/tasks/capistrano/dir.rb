namespace :dir do

  desc "Initialize transfer variables"
  task :init do
    set :dir_archive, "archive.tar.gz"

    run_locally do
      execute :mkdir, "-p", fetch(:vm_tmp_dir)
    end

    on roles(:app) do
      within release_path do
        execute :mkdir, "-p", fetch(:tmp_dir)
      end
    end
  end

  desc "Recursively push directory to remote"
  task :push, [:dir] do |t, args|
    invoke "dir:init"

    error "Could not locate local directory '#{args[:dir]}'" unless File.exist? args[:dir]

    on roles(:app) do
      within release_path do
        execute :mkdir, "-p", args[:dir]
      end
    end

    if fetch(:archive)
      on roles(:dev) do
        within fetch(:dev_path) do
          execute :tar, "-zcf", "#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}", "#{args[:dir]}/*"
        end
      end

      on release_roles(:app) do
        upload! "#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}", release_path
          .join("#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}")

        within release_path do
          execute :tar, "--no-overwrite-dir -zxf", "#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}", "#{args[:dir]}/"
          execute :rm,"#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}"
        end
      end

      on roles(:dev) do
        within fetch(:dev_path) do
          execute :rm,"#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}"
        end
      end
    else
      on roles(:app) do
        upload! args[:dir], release_path.join(Pathname.new(args[:dir]).parent), {
          recursive: true
        }
      end
    end
  end

  desc "Recursively pull directory from remote"
  task :pull, [:dir] do |t, args|
    invoke "dir:init"

    run_locally do
      execute :mkdir, "-p", args[:dir]
    end

    if fetch(:archive)
      on release_roles(:app) do
        within release_path do
          execute :tar, "-hzcf", "#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}", "#{args[:dir]}/*"
          download! release_path.join("#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}"),
            "#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}"
          execute :rm,"#{fetch(:tmp_dir)}/#{fetch(:dir_archive)}"
        end
      end

      on roles(:dev) do
        within fetch(:dev_path) do
          execute :tar, "--no-overwrite-dir -zxf", "#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}", "#{args[:dir]}/"
          execute :rm,"#{fetch(:vm_tmp_dir)}/#{fetch(:dir_archive)}"
        end
      end
    else
      on roles(:app) do
        download! release_path.join(args[:dir]), Pathname.new(args[:dir]).parent, {
          recursive: true
        }
      end
    end
  end
end
