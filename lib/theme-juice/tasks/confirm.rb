# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Confirm < Task

      def initialize(opts = {})
        super
      end

      def execute
      end

      private

      def list_settings
        @project.inspect
      end
    end
  end
end
