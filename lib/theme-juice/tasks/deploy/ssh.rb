# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class SSH < Task

        def initialize
          super
        end

        def execute
          configure_ssh
        end

        private

        def configure_ssh
          @io.log "Configuring SSH options"

          @config.deployment.settings.each do |_, (key, value)|
            @env.cap.config.set :"#{key}", value
          end
        end
      end
    end
  end
end
