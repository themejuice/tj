# encoding: UTF-8

module ThemeJuice
  module Tasks
    class WPConfig < Task

      def initialize(opts = {})
        super

        @using_wp_config_sample = false
      end

      def execute
        return if !@project.wp_config_modify || @project.no_wp || @project.no_db

        unless wp_config_is_setup?
          @io.say "Could not find wp-config file to modify", {
            :color => :yellow, :icon => :notice }

          unless wp_config_sample_is_setup?
            @io.error "Could not find a wp-config-sample file either. Are you sure one exists in the project directory?"
          end

          @util.create_file(wp_config_file, { :verbose => @env.verbose,
            :capture => @env.quiet }) { File.read(wp_config_sample_file) }

          @using_wp_config_sample = true
        end

        modify_wp_config_settings({
          :db_name     => "#{@project.db_name}",
          :db_user     => "#{@project.db_user}",
          :db_password => "#{@project.db_pass}",
          :db_host     => "#{@project.db_host}",
          :wp_debug    => true
        })
      end

      private

      def wp_config_file
        "#{@project.location}/wp-config.php"
      end

      def wp_config_is_setup?
        File.exist? wp_config_file
      end

      def wp_config_sample_file
        "#{@project.location}/wp-config-sample.php"
      end

      def wp_config_sample_is_setup?
        File.exist? wp_config_sample_file
      end

      def modify_wp_config_settings(settings)
        if @using_wp_config_sample
          @io.log "Creating wp-config file from sample"
        else
          return unless @io.agree? "Do you want to modify your current wp-config settings?"
          @io.log "Modifying wp-config file"
        end

        settings.each do |setting, value|
          replacement = case value
                        when TrueClass, FalseClass
                          "define('#{setting.upcase}', #{value.to_s});"
                        else
                          "define('#{setting.upcase}', '#{value.to_s}');"
                        end

          @util.gsub_file wp_config_file, /define\(\W*#{setting}\W*,\s*['"]{0,1}(.*?)['"]{0,1}\)\;/mi,
            "#{replacement}", { :verbose => @env.verbose, :capture => @env.quiet }
        end
      end
    end
  end
end
