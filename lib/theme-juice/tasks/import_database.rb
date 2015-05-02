# encoding: UTF-8

module ThemeJuice
  module Tasks
    class ImportDatabase < Task

      def initialize(opts = {})
        super
      end

      def execute
        import_db
      end

      private

      def import_db
        if @project.db_import
          @io.log "Importing existing database"
          @util.run_vm "wp db import #{@project.db_import}"
        end
      end
    end
  end
end
