# encoding: UTF-8

module ThemeJuice
  module Tasks
    class WPCLI < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_wp_cli_file unless wp_cli_is_setup?
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
        @interact.log "Creating WP-CLI file"
        @util.create_file wp_cli_file, :verbose => @env.verbose do
%Q{require:
\s\s- vendor/autoload.php
ssh:
\s\svagrant:
\s\s\s\surl: #{@project.url}
\s\s\s\spath: #{@project.vm_location.sub @env.vm_path, "/srv"}
\s\s\s\scmd: cd #{@env.vm_path} && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%

}
        end
      end

      def remove_wp_cli_file
        @interact.log "Removing WP-CLI file"
        @util.remove_file wp_cli_file, :verbose => @env.verbose
      end
    end
  end
end

#       @interact.log "Setting up WP-CLI"
#
#       File.open "#{@opts[:project_location]}/wp-cli.local.yml", "a+" do |file|
#         file.puts "require:"
#         file.puts "\t- vendor/autoload.php"
#         file.puts "ssh:"
#         file.puts "\tvagrant:"
#         file.puts "\t\turl: #{@opts[:project_dev_url]}"
#         file.puts "\t\tpath: /srv/www/tj-#{@opts[:project_name]}"
#         file.puts "\t\tcmd: cd #{@env.vm_path} && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%"
#         file.puts "\n"
#       end
