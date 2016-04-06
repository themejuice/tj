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
        return if nginx_is_setup?

        @io.log "Creating nginx conf file"
        @util.create_file nginx_file, { :verbose => @env.verbose,
          :capture => @env.quiet } do
%Q(server {
  listen       80;
  server_name  .#{@project.url} ~(^|^[a-z0-9.-]*\\.)#{@project.xip_url}\\.\\d+\\.\\d+\\.\\d+\\.\\d+\\.xip\\.io$;
  root         #{@project.vm_srv};
  include      /etc/nginx/nginx-wp-common.conf;
#{ssl_configuration}}

)
        end
      end

      def remove_nginx_file
        @io.log "Removing nginx conf file"
        @util.remove_file nginx_file, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end

      def ssl_configuration
        return if @project.no_ssl
%Q{
  listen              443 ssl;
  ssl_certificate     {vvv_path_to_folder}/ssl/#{@project.url}.cert;
  ssl_certificate_key {vvv_path_to_folder}/ssl/#{@project.url}.key;
}
      end
    end
  end
end
