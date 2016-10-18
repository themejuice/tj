# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Stage < Task
      include Capistrano::DSL

      def initialize
        super

        @stage = @config.deployment.stages.send(@env.stage).symbolize_keys
      end

      def execute
        configure_stage
      end

      private

      def configure_stage
        @io.log "Configuring stage '#{@env.stage}'"

        server @stage.server, {
          :user  => @stage.user,
          :roles => @stage.roles
        }

        set :deploy_to,    -> { @stage.path }
        set :stage_url,    -> { @stage.url }
        set :uploads_dir,  -> { @stage.uploads }
        set :shared_files, -> { @stage.fetch(:shared, []).select { |f| !f.end_with? "/" } }
        set :shared_dirs,  -> { @stage.fetch(:shared, []).select { |f| f.end_with? "/" }.map { |f| f.chomp "/" } }
        set :tmp_dir,      -> { @stage.fetch(:tmp, "/tmp") }
        set :stage,        -> { @env.stage }
        set :rsync_ignore, -> { @stage.fetch(:ignore, []) }
      end
    end
  end
end
