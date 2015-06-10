# encoding: UTF-8

module ThemeJuice
  module Tasks
    class ForwardPorts < Entry

      def initialize(opts = {})
        super

        @entry = {
          :project => "forward ports",
          :file    => "#{@env.vm_path}/Customfile",
          :name    => "forward ports",
          :id      => "FP"
        }
      end

      def execute
        create_entry_file
        create_entry do
%Q{config.vm.network "forwarded_port", guest: 80,  host: 8080
config.vm.network "forwarded_port", guest: 443, host: 8443}
        end
      end

      def unexecute
        remove_entry
      end
    end
  end
end
