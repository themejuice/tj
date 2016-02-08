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
          @util.run "git clone #{@env.vm_box} . --depth 1", {
            :verbose => @env.verbose, :capture => @env.quiet }
        end
      end
    end
  end
end
