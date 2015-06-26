# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super

        @settings = @config.deployment.to_ostruct

        runner do
          @io.error "Not implemented"
        end
      end
    end
  end
end
