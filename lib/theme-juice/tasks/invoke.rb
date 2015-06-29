# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Invoke < Task
      attr_reader :args

      def initialize(args = [])
        super

        @args = args
      end

      def execute
        invoke_capistrano
      end

      private

      def invoke_capistrano
        @io.log "Invoking Capistrano"

        case
        when args.empty?
          @env.cap.invoke "deploy"
        when args.include?("rollback")
          @env.cap.invoke "deploy:rollback"
        else
          @env.cap.invoke *args
        end
      end
    end
  end
end
