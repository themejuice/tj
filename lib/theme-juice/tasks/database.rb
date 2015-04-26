# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Database < Task

      def initialize(opts = {})
        super
      end

      def execute
        if @project.db_host && @project.db_name && @project.db_user && @project.db_pass
          create_custom_db_file
          create_database
        end
      end

      def unexecute
        remove_database
        # drop_database if @project.drop_db
      end

      private

      def custom_db_file
        File.expand_path "#{@env.vm_path}/database/init-custom.sql"
      end

      def custom_db_file_is_setup?
        File.exist? custom_db_file
      end

      def create_custom_db_file
        unless custom_db_file_is_setup?
          @io.log "Creating custom database file"
          @util.create_file custom_db_file, nil, :verbose => @env.verbose
        end
      end

      def database_is_setup?
        File.readlines(custom_db_file).grep(/(#(#*)? Begin '#{@project.name}' DB)/m).any?
      end

      def create_database
        unless database_is_setup?
          @io.log "Creating database entries"
          @util.append_to_file custom_db_file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}' DB
CREATE DATABASE IF NOT EXISTS `#{@project.db_name}`;
GRANT ALL PRIVILEGES ON `#{@project.db_name}`.* TO '#{@project.db_user}'@'localhost' IDENTIFIED BY '#{@project.db_pass}';
# End '#{@project.name}' DB

}
          end
        end
      end

      def remove_database
        @io.log "Removing database entries"
        @util.gsub_file custom_db_file, /(#(#*)? Begin '#{@project.name}' DB)(.*?)(#(#*)? End '#{@project.name}' DB)\n+/m,
          "", :verbose => @env.verbose
      end

      def drop_database
        # @io.log "Dropping database"
      end
    end
  end
end
