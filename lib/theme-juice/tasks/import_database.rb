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
          @util.run_inside_vm [], :verbose => @env.verbose do |cmds|
            cmds << "cd #{@project.vm_srv}"
            cmds << "wp db import #{@project.db_import}"
          end
        end
      end
    end
  end
end
