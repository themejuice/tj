# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DotEnv < Task

      def initialize(opts = {})
        super
      end

      def execute
        unless @project.no_wp
          create_dot_env_file unless dot_env_is_setup?
        end
      end

      def unexecute
        remove_dot_env_file
      end

      private

      def dot_env_file
        "#{@project.location}/.env.development"
      end

      def dot_env_is_setup?
        File.exist? dot_env_file
      end

      def create_dot_env_file
        @interact.log "Creating .env file"
        @util.create_file dot_env_file, { :verbose => @env.verbose, :pretend => @env.dryrun } do
%Q{DB_NAME=#{@project.db_name}
DB_USER=#{@project.db_user}
DB_PASSWORD=#{@project.db_pass}
DB_HOST=#{@project.db_host}
WP_HOME=http://#{@project.url}
WP_SITEURL=http://#{@project.url}/wp

}
        end
      end

      def remove_dot_env_file
        @interact.log "Removing .env file"
        @util.remove_file dot_env_file, { :verbose => @env.verbose,
          :pretend => @env.dryrun }
      end
    end
  end
end
