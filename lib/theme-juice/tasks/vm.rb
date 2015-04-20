# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VM < Task

      def initialize(opts = {})
        super
      end

      def execute
        @interact.log "Running method 'execute' for #{self.class.name}"
        create_path
      end

      def unexecute
        @interact.log "Running method 'unexecute' for #{self.class.name}"
        remove_path
      end

      private

      def create_path
        @interact.log "Creating path"
        @util.create_file "foo.rb", "bar", :verbose => @env.verbose
      end

      def remove_path
        @interact.log "Removing path"
        @util.remove_file "foo.rb", "bar", :verbose => @env.verbose
      end
    end
  end
end
