# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Confirm < Task

      def initialize(opts = {})
        super
      end

      def execute
        confirm
      end

      private

      def confirm
        @interact.list "Your settings :", :yellow, settings
        unless @interact.agree? "Do these settings look correct?"
          @interact.error "Dang typos..."
        end
      end

      def settings
        if @env.verbose
          @env.inspect + @project.inspect
        else
          @project.inspect
        end
      end
    end
  end
end
