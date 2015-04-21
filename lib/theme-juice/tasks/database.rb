# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Database < Task

      def initialize(opts = {})
        super
      end

      def execute
        unless @project.no_db || @project.no_wp
          create_custom_file unless custom_file_is_setup?
          create_database    unless database_is_setup?
        end
      end

      def unexecute
        remove_database
        drop_database
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/database/init-custom.sql"
      end

      def custom_file_is_setup?
        File.exist? custom_file
      end

      def create_custom_file
        @interact.log "Creating custom file"
        @util.create_file custom_file, nil, :verbose => @env.verbose
      end

      def database_is_setup?
        File.readlines(custom_file).grep(/(#(#*)? Begin '#{@project.name}')/m).any?
      end

      def create_database
        @interact.log "Creating database"
        @util.append_to_file custom_file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}'
CREATE DATABASE IF NOT EXISTS `#{@project.db_name}`;
GRANT ALL PRIVILEGES ON `#{@project.db_name}`.* TO '#{@project.db_user}'@'localhost' IDENTIFIED BY '#{@project.db_pass}';
# End '#{@project.name}'

}
        end
      end

      def remove_database
        @interact.log "Removing database"
        @util.gsub_file custom_file, /(#(#*)? Begin '#{@project.name}')(.*?)(#(#*)? End '#{@project.name}')\n+/m,
          "", :verbose => @env.verbose
      end

      def drop_database
        @interact.log "Dropping database"
      end
    end
  end
end
