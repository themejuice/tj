# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Hosts < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_hosts_file
      end

      def unexecute
        remove_hosts_file
      end

      private

      def hosts_file
        "#{@project.location}/vvv-hosts"
      end

      def hosts_is_setup?
        File.exist? hosts_file
      end

      def create_hosts_file
        unless hosts_is_setup?
          @interact.log "Creating hosts file"
          @util.create_file hosts_file, "#{@project.url}",
            :verbose => @env.verbose
        end
      end

      def remove_hosts_file
        @interact.log "Removing hosts file"
        @util.remove_file hosts_file, :verbose => @env.verbose
      end
    end
  end
end
