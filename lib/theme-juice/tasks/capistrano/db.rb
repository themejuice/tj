# encoding: UTF-8

namespace :db do

  desc "Initialize database variables"
  task :init do
    set :timestamp, Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    set :remote_db, "#{fetch(:timestamp)}.#{fetch(:stage)}.sql"
    set :vm_db, "#{fetch(:timestamp)}.local.sql"
  end

  desc "Backup database on remote to local"
  task :backup do
    set :timestamp_backup, Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    set :remote_db_backup, "#{fetch(:timestamp_backup)}.#{fetch(:stage)}.backup.sql"

    on release_roles(:db) do

      within release_path do
        execute :mkdir, "-p", fetch(:tmp_dir)
        execute :wp, :db, :export, "#{fetch(:tmp_dir)}/#{fetch(:remote_db_backup)}", "--add-drop-table"
      end

      run_locally do
        execute :mkdir, "-p", fetch(:vm_backup_dir)
      end

      download! release_path.join("#{fetch(:tmp_dir)}/#{fetch(:remote_db_backup)}"),
        "#{fetch(:vm_backup_dir)}/#{fetch(:remote_db_backup)}"

      within release_path do
        execute :rm, "#{fetch(:tmp_dir)}/#{fetch(:remote_db_backup)}"
      end
    end
  end

  desc "Push local database to remote"
  task :push do
    invoke "db:backup"
    invoke "db:init"

    on roles(:dev) do
      within fetch(:dev_path) do
        execute :wp, :db, :export, "#{fetch(:vm_backup_dir)}/#{fetch(:vm_db)}"
      end
    end

    on release_roles(:db) do
      upload! "#{fetch(:vm_backup_dir)}/#{fetch(:vm_db)}", release_path
        .join("#{fetch(:tmp_dir)}/#{fetch(:vm_db)}")

      within release_path do
        execute :wp, :db, :import, "#{fetch(:tmp_dir)}/#{fetch(:vm_db)}"
        execute :rm, "#{fetch(:tmp_dir)}/#{fetch(:vm_db)}"
        execute :wp, "search-replace", fetch(:vm_url), fetch(:stage_url), fetch(:wpcli_args) || "--skip-columns=guid"
      end
    end

    on roles(:dev) do
      within fetch(:dev_path) do
        execute :rm, "#{fetch(:vm_backup_dir)}/#{fetch(:vm_db)}"
      end
    end
  end

  desc "Pull remote database to local"
  task :pull do
    invoke "db:backup"
    invoke "db:init"

    on release_roles(:db) do
      within release_path do
        execute :wp, :db, :export, "#{fetch(:tmp_dir)}/#{fetch(:remote_db)}"
        download! release_path.join("#{fetch(:tmp_dir)}/#{fetch(:remote_db)}"),
          "#{fetch(:vm_backup_dir)}/#{fetch(:remote_db)}"
        execute :rm, "#{fetch(:tmp_dir)}/#{fetch(:remote_db)}"
      end
    end

    on roles(:dev) do
      within fetch(:dev_path) do
        execute :wp, :db, :import, "#{fetch(:vm_backup_dir)}/#{fetch(:remote_db)}"
        execute :rm, "#{fetch(:vm_backup_dir)}/#{fetch(:remote_db)}"
        execute :wp, "search-replace", fetch(:stage_url), fetch(:vm_url), fetch(:wpcli_args) || "--skip-columns=guid"
      end
    end
  end
end
