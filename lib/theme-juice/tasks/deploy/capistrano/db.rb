#
# Database migration
#
namespace :db do

  desc "Initialize database variables"
  task :init do
    set :timestamp, Time.now.strftime("%Y%m%d%H%M%S")
    set :remote_backup_dir, fetch(:tmp_dir, "tmp")
    set :vagrant_backup_dir, fetch(:vagrant_tmp_dir, "backup")
    set :remote_db, "#{fetch(:timestamp)}.#{fetch(:stage)}.sql"
    set :vagrant_db, "#{fetch(:timestamp)}.local.sql"
  end

  desc "Backup database on remote to local"
  task :backup do
    invoke "db:init"

    on roles :db do

      within release_path do
        execute :wp, :db, :export, "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}", "--add-drop-table"
      end

      run_locally do
        execute :mkdir, "-p", fetch(:vagrant_backup_dir)
      end

      download! "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}", "#{fetch(:vagrant_backup_dir)}/#{fetch(:remote_db)}"

      within release_path do
        execute :rm, "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}"
      end
    end
  end

  desc "Restore local database from backup"
  task :restore do
    invoke "db:init"

    on roles :db do
      run_locally do

        # Check if backups exist
        if Dir.glob("#{fetch(:vagrant_backup_dir)}/*").empty?
          puts "No databases were found in #{Dir.pwd}/#{fetch(:vagrant_backup_dir)}/ to restore from"
        else

          # Get array of all backup files
          backups = []
          Dir.glob("#{fetch(:vagrant_backup_dir)}/*").select { |f| if !File.directory?(f) then backups << f end }

            # Create menu of backups
            HighLine::choose do |menu|
              backups.each do |backup|

                # Create choice for each backup basename (timestamped)
                menu.choice backup do
                  puts "Restoring local database to #{File.basename(backup)}..."

                  # Import database within VM, perform search-replace
                  on roles :dev do
                    within fetch(:dev_path) do
                      execute :wp, :db, :import, backup
                      execute :wp, "search-replace", fetch(:stage_url), fetch(:vagrant_url), fetch(:wpcli_args) || "--skip-columns=guid"
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    desc "Clean up local database backups (removes all but most recent)"
    task :clean do
      invoke "db:init"

      on roles :db do
        run_locally do

          # Remove backup dir if empty
          if Dir.glob("#{fetch(:vagrant_backup_dir)}/*").empty?
            execute :rmdir, fetch(:vagrant_backup_dir)
          else

            # Get array of all backup timestamps
            backups = []
            Dir.glob("#{fetch(:vagrant_backup_dir)}/*").select { |f| if !File.directory?(f) then backups << File.basename(f, ".*").to_i end }

              # Remove all but newest backup
              Dir.glob("#{fetch(:vagrant_backup_dir)}/*").each do |backup|
                unless File.basename(backup, ".*").to_i == backups.max
                  execute :rm, backup
                end
              end
            end
          end
        end
      end

      desc "Push local database to remote"
      task :push do
        invoke "db:backup"

        # on roles :db do
        #     invoke "wpcli:db:push"
        # end

        on roles :dev do
          within fetch(:dev_path) do
            execute :wp, :db, :export, "#{fetch(:vagrant_backup_dir)}/#{fetch(:vagrant_db)}"
          end
        end

        on roles :web do
          upload! "#{fetch(:vagrant_backup_dir)}/#{fetch(:vagrant_db)}", "#{fetch(:remote_backup_dir)}/#{fetch(:vagrant_db)}"

          within release_path do
            execute :wp, :db, :import, "#{fetch(:remote_backup_dir)}/#{fetch(:vagrant_db)}"
            execute :rm, "#{fetch(:remote_backup_dir)}/#{fetch(:vagrant_db)}"
            execute :wp, "search-replace", fetch(:vagrant_url), fetch(:stage_url), fetch(:wpcli_args) || "--skip-columns=guid"
          end
        end

        on roles :dev do
          within fetch(:dev_path) do
            execute :rm, "#{fetch(:vagrant_backup_dir)}/#{fetch(:vagrant_db)}"
          end
        end
      end

      desc "Pull remote database to local"
      task :pull do
        invoke "db:backup"

        # on roles :db do
        #     invoke "wpcli:db:pull"
        # end

        on roles :db do
          within release_path do
            execute :wp, :db, :export, "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}"
            download! "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}", "#{fetch(:vagrant_backup_dir)}/#{fetch(:remote_db)}"
            execute :rm, "#{fetch(:remote_backup_dir)}/#{fetch(:remote_db)}"
          end
        end

        on roles :dev do
          within fetch(:dev_path) do
            execute :wp, :db, :import, "#{fetch(:vagrant_backup_dir)}/#{fetch(:remote_db)}"
            execute :rm, "#{fetch(:vagrant_backup_dir)}/#{fetch(:remote_db)}"
            execute :wp, "search-replace", fetch(:stage_url), fetch(:vagrant_url), fetch(:wpcli_args) || "--skip-columns=guid"
          end
        end
      end
    end
