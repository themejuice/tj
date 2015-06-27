# encoding: UTF-8

module ThemeJuice
  module Tasks
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

        if @env.cap.args.empty?
          @env.cap.app.invoke :deploy
        else
          @env.cap.app.invoke *@env.cap.args
        end
      end
    end
  end
end
