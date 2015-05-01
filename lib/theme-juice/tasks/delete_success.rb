# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteSuccess < Task

      def initialize(opts = {})
        super

        @vm = Tasks::VMRestart.new(opts)
      end

      def unexecute
        restart
        success
      end

      private

      def restart
        if @project.restart
          @vm.execute
        end
      end

      def success
        @io.speak "Successfully removed project '#{@project.name}'", :color => :yellow
      end
    end
  end
end
