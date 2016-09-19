# encoding: UTF-8

module ThemeJuice
  module Migrations
    class ForwardPorts < Migration

      def initialize(opts = {})
        super
      end

      def execute
        return if migration_is_completed?
        replace_content
      end

      private

      def migration_is_completed?
        File.read(migration_file).include? new_content.gsub(/\\%|\\\\/, "\\")
      end

      def migration_file
        "#{@env.vm_path}/Customfile"
      end

      def replace_content
        @io.log "Migrating forwarded ports entry"
        @util.gsub_file migration_file, old_content, new_content, {
          :verbose => @env.verbose, :capture => @env.quiet }
      end

      def old_content
%Q{if defined? VagrantPlugins::Triggers
  config.trigger.after [:up, :reload, :provision], :stdout => true do
    system \%Q{echo "
rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 8443
" | sudo pfctl -ef - >/dev/null 2>&1; echo "Forwarding ports (80 => 8080)\\nForwarding ports (443 => 8443)"}
  end
  config.trigger.after [:halt, :suspend, :destroy], :stdout => true do
    system \%Q{sudo pfctl -F all -f /etc/pf.conf >/dev/null 2>&1; echo "Removing forwarded ports (80 => 8080)\\nRemoving forwarded ports (443 => 8443)"}
  end
end}
      end

      def new_content
%Q{if Vagrant.has_plugin?("vagrant-triggers")
  config.trigger.before [:reload, :provision], :stdout => true do
    system \%Q{sudo pfctl -F all -f /etc/pf.conf >/dev/null 2>&1; echo "Removing forwarded ports (80 => 8080)\\nRemoving forwarded ports (443 => 8443)"}
  end
  config.trigger.after [:up, :reload, :provision], :stdout => true do
    system \%Q{echo "
rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
rdr pass inet proto tcp from any to any port 443 -> 127.0.0.1 port 8443
" | sudo pfctl -ef - >/dev/null 2>&1; echo "Forwarding ports (80 => 8080)\\nForwarding ports (443 => 8443)"}
  end
  config.trigger.after [:halt, :suspend, :destroy], :stdout => true do
    system \%Q{sudo pfctl -F all -f /etc/pf.conf >/dev/null 2>&1; echo "Removing forwarded ports (80 => 8080)\\nRemoving forwarded ports (443 => 8443)"}
  end
end}
      end
    end
  end
end
