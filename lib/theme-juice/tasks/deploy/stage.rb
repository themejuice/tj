# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Stage < Task

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

          @env.cap.config.server @stage.server, {
            :user  => @stage.user,
            :roles => @stage.roles.map { |i| i.to_sym }
          }

          @env.cap.config.set :stage,       @env.cap.stage
          @env.cap.config.set :deploy_to,   @stage.path
          @env.cap.config.set :stage_url,   @stage.url
          @env.cap.config.set :uploads_dir, @stage.uploads
          @env.cap.config.set :tmp_dir,     @stage.tmp
        end
      end
    end
  end
end
