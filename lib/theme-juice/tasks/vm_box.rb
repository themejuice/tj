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
        File.exist? @env.vm_path
      end

      def install_box
        unless box_is_installed?
          @io.log "Installing Vagrant box"
          @util.run "git clone #{@env.vm_box} #{@env.vm_path} --depth 1",
            :verbose => @env.verbose
        end
      end
    end
  end
end
