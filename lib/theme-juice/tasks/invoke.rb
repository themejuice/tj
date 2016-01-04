# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Invoke < Task
      include Capistrano::DSL

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

        @env.cap.invoke "load:defaults"
        @env.cap.invoke "load:settings"

        case args.last
        when nil
          @env.cap.invoke "deploy"
        when "rollback"
          @env.cap.invoke "deploy:rollback"
        when "setup", "check"
          @env.cap.invoke "deploy:check"
        else
          @env.cap.invoke *args
        end
      rescue SSHKit::Command::Failed, SSHKit::Runner::ExecuteError => err
        @env.cap.invoke "deploy:failed"
        @io.error "Capistrano has encountered a fatal error", StandardError do
          puts err.message.force_encoding "UTF-8"
        end
      end
    end
  end
end
