# encoding: UTF-8

module ThemeJuice
  module Tasks
    class InitSuccess < Task

      def initialize(opts = {})
        super
      end

      def execute
        success
      end

      private

      def success
        @io.success "Successfully initialized VM"
        @io.list "Your settings :", :blue, @env.inspect
      end
    end
  end
end
