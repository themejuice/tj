# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateSuccess < Task

      def initialize(opts = {})
        super
      end

      def execute
        success
      end

      private

      def success
        @io.speak "Successfully created project '#{@project.name}'", :color => :red
      end
    end
  end
end
