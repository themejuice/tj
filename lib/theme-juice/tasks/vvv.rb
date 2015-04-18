# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VVV < Task

      def initialize(opts = {})
        super

        @io.destination_root = @project.location

        runner do |tasks|
          tasks << :path
        end
      end

      def do
        @interact.log "Running method 'do' for #{self.class.name}"
        @tasks.each { |task| self.send "do_#{task}" }
      end

      def undo
        @interact.log "Running method 'undo' for #{self.class.name}"
        @tasks.each { |task| self.send "undo_#{task}" }
      end

      private

      def do_path
        @interact.log "Creating path"
        @io.create_file "foo.rb", "bar"
      end

      def undo_path
        @interact.log "Removing path"
        @io.remove_file "foo.rb", "bar"
      end
    end
  end
end
