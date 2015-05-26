# encoding: UTF-8

module ThemeJuice
  module Tasks
    class CreateSuccess < Task

      def initialize(opts = {})
        super
      end

      def execute
        success
      end

      private

      def success
        @io.success "Successfully created project '#{@project.name}'"
        @io.list "Your settings :", :blue, settings
      end

      def settings
        if @env.verbose
          @env.inspect + @project.inspect
        else
          @project.inspect
        end
      end
    end
  end
end
