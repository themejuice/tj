# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Nginx < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_nginx_file
      end

      def unexecute
        remove_nginx_file
      end

      private

      def nginx_file
        "#{@env.vm_path}/config/nginx-config/sites/#{@project.name}.conf"
      end

      def nginx_is_setup?
        File.exist? nginx_file
      end

      def create_nginx_file
        unless nginx_is_setup?
          @io.log "Creating nginx conf file"
          @util.create_file nginx_file, :verbose => @env.verbose do
%Q(server {
  listen       80;
  listen       443 ssl;
  server_name  .#{@project.url};
  root         #{@project.vm_srv};
  include      /etc/nginx/nginx-wp-common.conf;
}

)
          end
        end
      end

      def remove_nginx_file
        @io.log "Removing nginx conf file"
        @util.remove_file nginx_file, :verbose => @env.verbose
      end
    end
  end
end
