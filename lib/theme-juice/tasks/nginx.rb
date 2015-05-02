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
        "#{@project.location}/vvv-nginx.conf"
      end

      def nginx_is_setup?
        File.exist? nginx_file
      end

      def create_nginx_file
        unless nginx_is_setup?
          @io.log "Creating nginx file"
          @util.create_file nginx_file, :verbose => @env.verbose do
%Q{server \{
  listen 80;
  server_name .#{@project.url};
  root {vvv_path_to_folder};
  include /etc/nginx/nginx-wp-common.conf;
\}

}
          end
        end
      end

      def remove_nginx_file
        @io.log "Removing nginx file"
        @util.remove_file nginx_file, :verbose => @env.verbose
      end
    end
  end
end
