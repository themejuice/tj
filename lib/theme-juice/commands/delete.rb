# encoding: UTF-8

module ThemeJuice
  module Commands
    class Delete < Command

      def initialize(opts = {})
        super

        init_project

        runner do |tasks|
          tasks << Tasks::DeleteConfirm.new
          tasks << Tasks::Database.new
          tasks << Tasks::VMLocation.new
          tasks << Tasks::SyncedFolder.new
          tasks << Tasks::DNS.new
          tasks << Tasks::VMRestart.new
          tasks << Tasks::DeleteSuccess.new
        end
      end

      private

      def init_project
        @project.name        = @opts.fetch("name") { name }
        @project.url         = @opts.fetch("url") { url }
        @project.db_drop     = @opts.fetch("db_drop", false)
        @project.vm_restart  = @opts.fetch("vm_restart", false)
        @project.vm_root     = vm_root
        @project.vm_location = vm_location
        @project.vm_srv      = vm_srv
      end

      def name
        name = @io.prompt "What's the project name?"

        unless @list.projects.include? name
          @io.error "Project '#{name}' doesn't exist"
        end

        name
      end

      def url
        url = @io.prompt "What is the project's development url?", :default => "#{@project.name}.dev"

        unless @list.urls.include? url
          @io.notice "Project url '#{url}' doesn't exist within DNS records. Skipping..."
        end

        url
      end
    end
  end
end
