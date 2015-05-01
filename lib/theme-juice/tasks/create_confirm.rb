# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateConfirm < Task

      def initialize(opts = {})
        super
      end

      def execute
        confirm
      end

      private

      def confirm
        @io.list "Your settings:", :yellow, settings
        unless @io.agree? "Do these settings look correct?"
          @io.error "Dang typos..."
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
