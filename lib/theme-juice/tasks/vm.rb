# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VM < Task

      def initialize(opts = {})
        super

        runner do |tasks|
          tasks << :path
        end
      end

      def execute
        @interact.log "Running method 'execute' for #{self.class.name}"
        @tasks.each { |task| self.send task, :execute }
      end

      def unexecute
        @interact.log "Running method 'unexecute' for #{self.class.name}"
        @tasks.reverse.each { |task| self.send task, :unexecute }
      end

      private

      def path(action)
        case action
        when :execute
          execute_path
        when :unexcute
          unexecute_path
        end
      end

      def execute_path
        @interact.log "Creating path"
        @util.create_file "foo.rb", "bar"
      end

      def unexecute_path
        @interact.log "Removing path"
        @util.remove_file "foo.rb", "bar"
      end
    end
  end
end
