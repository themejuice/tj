# encoding: UTF-8

module ThemeJuice
  module Tasks
    class WPCLI < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_wp_cli_file
      end

      def unexecute
        remove_wp_cli_file
      end

      private

      def wp_cli_file
        "#{@project.location}/wp-cli.local.yml"
      end

      def wp_cli_is_setup?
        File.exist? wp_cli_file
      end

      def create_wp_cli_file
        return if wp_cli_is_setup? || @project.no_wp_cli || @project.no_wp

        @io.log "Creating WP-CLI file"
        @util.create_file wp_cli_file, { :verbose => @env.verbose,
          :capture => @env.quiet } do
%Q{@development:
  ssh: vagrant@#{@env.vm_ip}:#{@project.vm_srv}
}
        end
      end

      def remove_wp_cli_file
        @io.log "Removing WP-CLI file"
        @util.remove_file wp_cli_file
      end
    end
  end
end
