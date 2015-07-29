# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMLocation < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_path
      end

      def unexecute
        remove_path
      end

      private

      def create_path
        @io.log "Creating project location in VM"
        @util.empty_directory @project.vm_location, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end

      def remove_path
        @io.log "Removing project location in VM"
        @util.remove_dir @project.vm_location, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end
  end
end
