# encoding: UTF-8

module ThemeJuice
  module Commands
    class Subcommand < Command

      def initialize(opts = {})
        super

        @project.vm_root     = vm_root
        @project.vm_location = vm_location
      end
    end
  end
end
