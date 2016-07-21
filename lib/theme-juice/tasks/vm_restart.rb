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
        restart if @project.vm_restart
      end

      private

      def vm_is_up?
        res = false

        @util.inside @env.vm_path do
          res = @util.run("vagrant status --machine-readable", {
            :verbose => @env.verbose, :capture => true }).include? "running"
        end

        res
      end

      def restart
        @io.log "Restarting VM"
        @util.inside @env.vm_path do
          @util.run [] do |cmds|
            cmds << "vagrant halt" if vm_is_up?
            cmds << "vagrant up"
          end
        end
      end
    end
  end
end
