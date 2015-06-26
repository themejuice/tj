module ThemeJuice
  module Tasks
    class VMStage < Task

      def initialize
        super

        @vagrant = @config.deployment.stages.vagrant
      end

      def execute
        configure_vagrant_stage
      end

      private

      def configure_vagrant_stage
        @io.log "Configuring VM stage"

        @env.cap.config.server @vagrant.server, {
          :user       => @vagrant.user,
          :password   => @vagrant.pass,
          :roles      => %w{dev},
          :no_release => true
        }

        @env.cap.config.set :dev_path,            @vagrant.path
        @env.cap.config.set :vagrant_url,         @vagrant.url
        @env.cap.config.set :vagrant_uploads_dir, @vagrant.uploads
        @env.cap.config.set :vagrant_tmp_dir,     @vagrant.tmp
      end
    end
  end
end
