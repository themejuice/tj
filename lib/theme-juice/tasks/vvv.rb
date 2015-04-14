# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VVV < Task

      def initialize(opts = {})
        super

        runner do |tasks|
          tasks << path
        end
      end

      def do
        @interact.log "Running 'do' method for VVV task"
      end

      def undo
        @interact.log "Running 'undo' method for VVV task"
      end

    private

      def path
        @interact.prompt "Path" unless @opts.fetch "path", nil
      end
    end
  end
end
