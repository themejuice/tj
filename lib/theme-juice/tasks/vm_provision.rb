# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMProvision < Task

      def initialize(opts = {})
        super
      end

      def execute
        provision
      end

      private

      def provision
        @io.log "Provisioning VM"
        @util.inside @env.vm_path do
          @util.run "vagrant provision", :verbose => @env.verbose
        end
      end
    end
  end
end
