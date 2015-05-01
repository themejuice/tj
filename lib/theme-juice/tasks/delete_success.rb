# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteSuccess < Task

      def initialize(opts = {})
        super
      end

      def unexecute
        success
      end

      private

      def success
        @io.speak "Project '#{@project.name}' removed", :color => :red
      end
    end
  end
end
