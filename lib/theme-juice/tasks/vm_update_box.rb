# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMUpdateBox < Task

      def initialize(opts = {})
        super
      end

      def execute
        update_box
      end

      private

      def box_is_installed?
        File.exist? "#{@env.vm_path}/Vagrantfile"
      end

      def update_box
        return unless box_is_installed?

        @io.log "Updating Vagrant box"
        @util.inside @env.vm_path do
          @util.run [], { :verbose => @env.verbose,
            :capture => @env.quiet } do |cmds|
            cmds << "git fetch"
            if @env.vm_revision
              cmds << "git checkout '#{@env.vm_revision}'"
            else
              cmds << "git checkout master"
            end
            cmds << "git reset --hard"
          end
        end
      end
    end
  end
end
