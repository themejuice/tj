# encoding: UTF-8

module ThemeJuice
  module Tasks
    class InitConfirm < Task

      def initialize(opts = {})
        super
      end

      def execute
        confirm
      end

      private

      def confirm
        @io.list "Your settings:", :yellow, @env.inspect

        unless @io.agree? "Do these settings look correct?"
          @io.error "Well, dang. Maybe check out the various flags you can use."
        end
      end
    end
  end
end
