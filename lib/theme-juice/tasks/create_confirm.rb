# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateConfirm < Task

      def initialize(opts = {})
        super
      end

      def execute
        is_user_a_smarty_pants?
        confirm
      end

      private

      def is_user_a_smarty_pants?
        if @env.yolo && @project.use_defaults
          @io.say "Well, don't you just have everything all figured out?", {
            :color => :blue, :icon => :general }
        end
      end

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
