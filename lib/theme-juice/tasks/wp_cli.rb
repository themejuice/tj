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
        unless wp_cli_is_setup?
          @io.log "Creating WP-CLI file"
          @util.create_file wp_cli_file, :verbose => @env.verbose do
%Q{require:
  - vendor/autoload.php
ssh:
  vagrant:
    url: #{@project.url}
    path: #{@project.vm_srv_location}
    cmd: cd #{@env.vm_path} && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%

}
          end
        end
      end

      def remove_wp_cli_file
        @io.log "Removing WP-CLI file"
        @util.remove_file wp_cli_file, :verbose => @env.verbose
      end
    end
  end
end
