# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super
        runner { @io.error "Not implemented" }
      end
    end
  end
end
