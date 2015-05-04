# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteConfirm < Task

      def initialize(opts = {})
        super
      end

      def unexecute
        confirm
      end

      private

      def confirm
        unless @io.agree? "Are you sure you want to remove '#{@project.name}'?"
          @io.error "Aborting mission"
        end
      end
    end
  end
end
