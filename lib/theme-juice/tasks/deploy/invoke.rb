# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Invoke < Task

        def initialize
          super
        end

        def execute
          @io.log "Invoking Capistrano"
          
          @env.cap.app.invoke(@env.cap.stage, @env.cap.args)
        end
      end
    end
  end
end
