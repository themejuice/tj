# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteSuccess < Task

      def initialize(opts = {})
        super
      end

      def unexecute
        success
      end

      private

      def success
        @io.success "Successfully removed project '#{@project.name}'"
      end
    end
  end
end
