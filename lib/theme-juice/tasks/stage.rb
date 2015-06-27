# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Stage < Task
      include Capistrano::DSL

      def initialize
        super

        @stage = @config.deployment.stages.send(@env.cap.stage)
      end

      def execute
        configure_stage
      end

      private

      def configure_stage
        @io.log "Configuring stage '#{@env.cap.stage}'"

        stages = "#{@env.cap.stage}"

        server @stage.server, {
          :user  => @stage.user,
          :roles => @stage.roles
        }

        set :deploy_to,   @stage.path
        set :stage_url,   @stage.url
        set :uploads_dir, @stage.uploads
        set :tmp_dir,     @stage.tmp
        set :stage,       @env.cap.stage
      end
    end
  end
end
