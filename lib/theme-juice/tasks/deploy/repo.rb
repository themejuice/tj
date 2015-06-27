# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Repo < Task
        include Capistrano::DSL

        def initialize
          super
        end

        def execute
          configure_scm
        end

        private

        def configure_scm
          @io.log "Configuring repository"

          @config.deployment.repository.symbolize_keys.each do |key, value|
            set key, value
          end
        end
      end
    end
  end
end
