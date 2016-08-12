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
          if @env.nginx
            tasks << Tasks::Nginx.new
          else
            tasks << Tasks::Apache.new
          end
          tasks << Tasks::VMLocation.new
          tasks << Tasks::SyncedFolder.new
          tasks << Tasks::DNS.new
          if @project.vm_restart
            tasks << Tasks::VMRestart.new
          else
            tasks << Tasks::VMProvision.new
          end
          tasks << Tasks::DeleteSuccess.new
        end
      end

      private

      def init_project
        @project.name       = @opts.fetch("name")       { name }
        @project.url        = @opts.fetch("url")        { url }
        @project.db_drop    = @opts.fetch("db_drop")    { false }
        @project.vm_restart = @opts.fetch("vm_restart") { false }
        @project.vm_root
        @project.vm_location
        @project.vm_srv
      end

      def name
        name = @io.ask "What's the project name?"

        unless @list.projects.include? name
          @io.error "Project '#{name}' doesn't exist"
        end

        name
      end

      def url
        return "#{@project.name}.dev" if @env.no_landrush

        url = @io.ask "What is the project's development url?", :default => "#{@project.name}.dev"

        unless @list.urls.include? url
          @io.notice "Project url '#{url}' doesn't exist within DNS records. Skipping..."
        end

        url
      end
    end
  end
end
