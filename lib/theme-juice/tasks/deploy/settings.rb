# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Settings < Task

        def initialize
          super
        end

        def execute
          configure_settings
        end

        private

        def configure_settings
          @io.log "Configuring Capistrano"

          @config.deployment.settings.symbolize_keys.each do |key, value|
            @env.cap.config.set key, value
          end
        end
      end
    end
  end
end
