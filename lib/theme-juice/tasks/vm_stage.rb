# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMStage < Task
      include Capistrano::DSL

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

        server @vagrant.server, {
          :user       => @vagrant.user,
          :password   => @vagrant.pass,
          :roles      => @vagrant.roles,
          :no_release => true
        }

        set :dev_path,            @vagrant.path
        set :vagrant_url,         @vagrant.url
        set :vagrant_uploads_dir, @vagrant.uploads
        set :vagrant_tmp_dir,     @vagrant.tmp
      end
    end
  end
end
