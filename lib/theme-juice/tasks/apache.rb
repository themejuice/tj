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
        "#{@env.vm_path}/config/apache-config/#{@project.name}.conf"
      end

      def apache_is_setup?
        File.exist? apache_file
      end

      def create_apache_file
        unless apache_is_setup?
          @io.log "Creating apache conf file"
          @util.create_file apache_file, :verbose => @env.verbose do
%Q{<VirtualHost *:80>
  DocumentRoot #{@project.vm_srv}
  ServerName #{@project.url}
  ServerAlias *.#{@project.url}
</VirtualHost>

}
          end
        end
      end

      def remove_apache_file
        @io.log "Removing apache file"
        @util.remove_file apache_file, :verbose => @env.verbose
      end
    end
  end
end
