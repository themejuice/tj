# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Invoke < Task

      def initialize(args)
        super

        @args = args
      end

      def execute
        invoke_capistrano
      end

      private

      def invoke_capistrano
        @io.log "Invoking Capistrano"

        if @args.empty?
          @env.cap.invoke :deploy
        else
          @env.cap.invoke *@args
        end
      end
    end
  end
end
