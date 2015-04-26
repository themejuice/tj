# encoding: UTF-8

module ThemeJuice
  module Tasks
    class DNS < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_dns
      end

      def unexecute
        remove_dns
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/Customfile"
      end

      def dns_is_setup?
        File.readlines(custom_file).grep(/(#(#*)? Begin '#{@project.name}' DNS)/m).any?
      end

      def create_dns
        unless dns_is_setup?
          @io.log "Creating DNS entries"
          @util.append_to_file custom_file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}' DNS
if defined? VagrantPlugins::Landrush
  config.landrush.host '#{@project.url}', '#{@env.vm_ip}'
elsif defined? VagrantPlugins::HostsUpdater
  config.hostsupdater.aliases << '#{@project.url}'
end
# End '#{@project.name}' DNS

}
          end
        end
      end

      def remove_dns
        @io.log "Removing DNS entries"
        @util.gsub_file custom_file, /(#(#*)? Begin '#{@project.name}' DNS)(.*?)(#(#*)? End '#{@project.name}' DNS)\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
