# encoding: UTF-8

module ThemeJuice
  module Tasks
    module Deploy
      class Invoke < Task

        def initialize
          super
        end

        def execute
          invoke_capistrano
        end

        private

        def invoke_capistrano
          @io.log "Invoking Capistrano"

          require "pp"
          pp @env.cap.config.send :servers
          pp @env.cap.config.send :config

          if @env.cap.args.empty?
            @env.cap.app.invoke :deploy
          else
            @env.cap.app.invoke *@env.cap.args
          end
        end
      end
    end
  end
end
