module ThemeJuice
  module Tasks
    class SCM < Task

      def initialize
        super
      end

      def execute
        configure_scm
      end

      private

      def configure_scm
        @io.log "Configuring SCM"

        @env.cap.config.set :repo_url, @config.deployment.repository.url
        @env.cap.config.set :branch,   @config.deployment.repository.branch
        @env.cap.config.set :scm,      @config.deployment.repository.scm
      end
    end
  end
end
