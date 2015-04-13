# encoding: UTF-8

module ThemeJuice
  module Commands
    class Create < Command

      def initialize(opts = {})
        super do |tasks|
          tasks << ::ThemeJuice::Tasks::VVV.new
        end
      end

      def execute
        @tasks.each { |task| task.create }
      end
    end
  end
end
