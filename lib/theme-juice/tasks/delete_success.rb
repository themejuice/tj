# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteSuccess < Task

      def initialize(opts = {})
        super

        @vm_restart = Tasks::VMRestart.new(opts)
      end

      def unexecute
        restart
        success
      end

      private

      def restart
        if @project.vm_restart
          @vm_restart.execute
        end
      end

      def success
        @io.success "Successfully removed project '#{@project.name}'"
      end
    end
  end
end
