# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DNS < Entry

      def initialize(opts = {})
        super

        @entry = {
          :project => @project.name,
          :file    => "#{@env.vm_path}/Customfile",
          :name    => "DNS",
          :id      => "DNS"
        }
      end

      def execute
        create_entry_file
        create_entry do
%Q{case
when Vagrant.has_plugin?("landrush")
  config.landrush.host '#{@project.url}', '#{@env.vm_ip}'
when Vagrant.has_plugin?("vagrant-hostsupdater")
  config.hostsupdater.aliases << '#{@project.url}'
end}
        end
      end

      def unexecute
        remove_landrush_entry
        remove_entry
      end

      private

      def remove_landrush_entry
        return if @env.no_landrush

        @io.log "Removing URL from Landrush"
        @util.run "vagrant landrush rm #{@project.url}", { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end
  end
end
