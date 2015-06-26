module ThemeJuice
  module Tasks
    class Rsync < Task

      def initialize
        super
      end

      def execute
        configure_rsync
      end

      private

      def configure_rsync
        @io.log "Configuring rsync"

        @env.cap.config.set :rsync_options, @config.deployment.rsync_options
      end
    end
  end
end
