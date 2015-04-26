# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMCustomfile < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_custom_file
      end

      def unexecute
        remove_custom_file
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/Customfile"
      end

      def custom_file_is_setup?
        File.exist? custom_file
      end

      def create_custom_file
        unless custom_file_is_setup?
          @interact.log "Creating customfile"
          @util.create_file custom_file, nil, :verbose => @env.verbose
        end
      end

      def remove_custom_file
        @interact.log "Removing customfile"
        @util.remove_file custom_file, :verbose => @env.verbose
      end
    end
  end
end
