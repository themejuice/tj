# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Rsync < Task
        include Capistrano::DSL

        def initialize
          super
        end

        def execute
          configure_rsync
        end

        private

        def configure_rsync
          @io.log "Configuring rsync"

          set :rsync_options, @config.deployment.rsync_options rescue nil
        end
      end
    end
  end
end
