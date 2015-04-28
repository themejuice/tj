# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Database < Entry

      def initialize(opts = {})
        super

        @entry_file = "#{@env.vm_path}/database/init-custom.sql"
        @entry_name = "database"
        @entry_id   = "DB"
      end

      def execute
        if @project.db_host && @project.db_name && @project.db_user && @project.db_pass
          create_entry_file
          create_entry do
%Q{
# CREATE DATABASE IF NOT EXISTS `#{@project.db_name}`;
# GRANT ALL PRIVILEGES ON `#{@project.db_name}`.* TO '#{@project.db_user}'@'localhost' IDENTIFIED BY '#{@project.db_pass}';
}
          end
        end
      end

      def unexecute
        remove_entry
        drop_database if @project.drop_db
      end

      private

      def drop_database
        @io.log "Dropping database"
      end
    end
  end
end
