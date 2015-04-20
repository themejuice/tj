# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VM < Task

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
        @interact.log "Setting up VM"
        # @util.create_file "foo.rb", "bar", :verbose => @env.verbose
      end

      def remove_path
        @interact.log "Removing VM"
        # @util.remove_file "foo.rb", "bar", :verbose => @env.verbose
      end
    end
  end
end
