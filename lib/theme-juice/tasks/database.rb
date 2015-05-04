# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Database < Entry

      def initialize(opts = {})
        super

        @entry = {
          :project => @project.name,
          :file    => "#{@env.vm_path}/database/init-custom.sql",
          :name    => "database",
          :id      => "DB"
        }
      end

      def execute
        if @project.db_host && @project.db_name && @project.db_user && @project.db_pass
          create_entry_file
          create_entry do
%Q{CREATE DATABASE IF NOT EXISTS `#{@project.db_name}`;
GRANT ALL PRIVILEGES ON `#{@project.db_name}`.* TO '#{@project.db_user}'@'localhost' IDENTIFIED BY '#{@project.db_pass}';}
          end
        end
      end

      def unexecute
        remove_entry
        drop_database
      end

      private

      def drop_database
        if @project.db_drop

          # Double check that the database should be dropped
          if @io.agree? "Are you sure you want to drop the database for '#{@project.name}'?"
            @io.log "Dropping database"
            @util.run_inside_vm [], :verbose => @env.verbose do |cmds|
              cmds << "cd #{@project.vm_srv}"
              cmds << "wp db drop --yes"
            end
          end
        end
      end
    end
  end
end
