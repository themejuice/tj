# encoding: UTF-8

module ThemeJuice
  module Tasks
    class ForwardPorts < Entry

      def initialize(opts = {})
        super

        @entry = {
          :project => "ports",
          :file    => "#{@env.vm_path}/Customfile",
          :name    => "ports",
          :id      => "FP"
        }
      end

      def execute
        unless @env.no_port_forward
          create_entry_file
          create_entry do
%Q{#{forward_host_ports}config.vm.network "forwarded_port", guest: 80,  host: 8080
config.vm.network "forwarded_port", guest: 443, host: 8443}
          end
        end
      end

      def unexecute
        remove_entry
      end

      private

      # @TODO I'd like to eventually support every OS. I'm only familiar with
      #  OSX, so that's why there's nothing else here
      def forward_host_ports
        if OS.osx?
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
end
}
        end
      end
    end
  end
end
