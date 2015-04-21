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
        @interact.list "Your settings :", :yellow, @project.inspect
        unless @interact.agree? "Do these settings look correct?"
          @interact.error "Dang typos..."
        end
      end
    end
  end
end
