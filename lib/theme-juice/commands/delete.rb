# encoding: UTF-8

module ThemeJuice
  module Commands
    class Delete < Command

      def initialize(opts = {})
        super

        @project.name        = @opts.fetch("name") { name }
        @project.url         = @opts.fetch("url") { url }
        @project.vm_root     = vm_root
        @project.vm_location = vm_location

        runner do |tasks|
          tasks << Tasks::VMLocation.new
          tasks << Tasks::Database.new
          tasks << Tasks::SyncedFolder.new
          tasks << Tasks::DNS.new
          tasks << Tasks::DeleteSuccess.new
          tasks << Tasks::VMRestart.new
        end
      end

      private

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
          @io.error "Project url '#{url}' doesn't exist within DNS records"
        end

        url
      end
    end
  end
end
