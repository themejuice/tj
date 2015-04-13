# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VVV < Task

      def initialize(opts = {})
        super do |tasks|
          tasks << path
        end
      end

      def create
        puts "Running create method for VVV task ..."
      end

      def delete
        puts "Running delete method for VVV task ..."
      end

      private

      def path
        @interaction.prompt "Path" unless @opts.fetch "path", nil
      end
    end
  end
end
