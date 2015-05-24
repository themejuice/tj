# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super

        init_project

        runner do |tasks|
          @io.error "Not implemented"
        end
      end

      private

      def init_project
        @project.vm_root     = vm_root
        @project.vm_location = vm_location
        @project.vm_srv      = vm_srv
      end
    end
  end
end
