# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DeleteConfirm < Task

      def initialize(opts = {})
        super
      end

      def unexecute
        boom?
        confirm
      end

      private

      def boom?
        if @env.yolo
          @io.say "Livin' on the edge, huh?!", { :color => :yellow,
            :icon => :general }
        end
      end

      def confirm
        unless @io.agree? "Are you sure you want to remove '#{@project.name}'?"
          @io.error "Aborting mission"
        end
      end
    end
  end
end
