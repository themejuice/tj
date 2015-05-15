# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMRestart < Task

      def initialize(opts = {})
        super
      end

      def execute
        restart
      end

      def unexecute
        if @project.vm_restart
          restart
        end
      end

      private

      def restart
        @io.log "Restarting VM"
        @util.inside @env.vm_path do
          @util.run "vagrant reload", :verbose => @env.verbose
        end
      end
    end
  end
end
