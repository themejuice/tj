# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Apache < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_apache_file
      end

      def unexecute
        remove_apache_file
      end

      private

      def apache_file
        "#{@env.vm_path}/config/apache-config/sites/#{@project.name}.conf"
      end

      def apache_is_setup?
        File.exist? apache_file
      end

      def create_apache_file
        return if apache_is_setup?
        
        @io.log "Creating apache conf file"
        @util.create_file apache_file, { :verbose => @env.verbose,
          :capture => @env.quiet } do
%Q{<VirtualHost *:80>
  DocumentRoot #{@project.vm_srv}
  ServerName #{@project.url}
  ServerAlias *.#{@project.url} #{@project.xip_url}.*.xip.io *.#{@project.xip_url}.*.xip.io
</VirtualHost>

}
        end
      end

      def remove_apache_file
        @io.log "Removing apache conf file"
        @util.remove_file apache_file, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end
  end
end
