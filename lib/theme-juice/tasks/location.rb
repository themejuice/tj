# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Location < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_path
      end

      private

      def create_path
        @io.log "Creating project location"
        @util.empty_directory @project.location, :verbose => @env.verbose
      end
    end
  end
end
