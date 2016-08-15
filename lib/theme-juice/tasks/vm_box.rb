# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMBox < Task

      def initialize(opts = {})
        super
      end

      def execute
        install_box
      end

      private

      def box_is_installed?
        File.exist? "#{@env.vm_path}/Vagrantfile"
      end

      def install_box
        return if box_is_installed?

        @io.log "Installing Vagrant box"
        @util.inside @env.vm_path do
          @util.run [], { :verbose => @env.verbose,
            :capture => @env.quiet } do |cmds|
            cmds << "git clone #{@env.vm_box} ."
            if @env.vm_revision
              cmds << "git checkout #{@env.vm_revision}"
            end
          end
        end
      end
    end
  end
end
