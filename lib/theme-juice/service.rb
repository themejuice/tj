# encoding: UTF-8

module ThemeJuice
    class Service
        include ::Thor::Actions
        include ::Thor::Shell

        #
        # @param {Hash} opts
        #
        def initialize(opts)
            @environment  = ::ThemeJuice::Environment
            @interaction  = ::ThemeJuice::Interaction
            @opts         = opts
            @config_path  = opts[:site_location]
            @config_regex = %r{^(\.)?(tj.y(a)?ml)}
        rescue => e
            @interaction.error "Whoops! Something went wrong!" do
                puts e
            end
        end

        private

        #
        # Run system commands
        #
        # @param {Array} commands
        #   Array of commands to run
        # @param {Bool}  silent   (true)
        #   Silence all output from command
        #
        # @return {Void}
        #
        def run(commands, silent = true)
            commands.map! { |cmd| cmd.to_s + " > /dev/null 2>&1" } if silent
            system commands.join "&&"
        end

        #
        # Verify config is properly setup, set global var
        #
        # @return {Void}
        #
        def use_config

            if config_is_setup?
                @config = YAML.load_file(Dir["#{@config_path}/*"].select { |f| File.basename(f) =~ @config_regex }.last)
            else
                @interaction.notice "Unable to find a 'tj.yml' file in '#{@config_path}'."

                unless @interaction.agree? "Would you like to create one?"
                    @interaction.error "A config file is needed to continue. Aborting mission."
                end

                setup_config
            end
        end

        #
        # Restart Vagrant
        #
        # @note Normally a simple 'vagrant reload' would work, but Landrush requires
        #   a 'vagrant up' to be fired for it to set up the DNS correctly.
        #
        # @return {Void}
        #
        def restart_vagrant
            @interaction.speak "Restarting VVV...", {
                color: :yellow,
                icon: :general
            }

            run [
                "cd #{@environment.vvv_path}",
                "vagrant halt",
                "vagrant up --provision",
            ], false
        end

        #
        # @return {Bool}
        #
        def setup_was_successful?
            vvv_is_setup? and dev_site_is_setup? and hosts_is_setup? and database_is_setup? and nginx_is_setup?
        end

        #
        # @return {Bool}
        #
        def removal_was_successful?
            !setup_was_successful?
        end

        #
        # @return {Bool}
        #
        def project_dir_is_setup?
            Dir.exist? "#{@opts[:site_location]}"
        end

        #
        # @return {Bool}
        #
        def config_is_setup?
            !Dir["#{@config_path}/*"].select { |f| File.basename(f) =~ @config_regex }.empty?
        end

        #
        # @return {Bool}
        #
        def vvv_is_setup?
            File.exist? File.expand_path(@environment.vvv_path)
        end

        #
        # @return {Bool}
        #
        def wildcard_subdomains_is_setup?
            File.readlines(File.expand_path("#{@environment.vvv_path}/Vagrantfile")).grep(/(config.landrush.enabled = true)/m).any?
        end

        #
        # @return {Bool}
        #
        def dev_site_is_setup?
            File.exist? "#{@opts[:site_dev_location]}"
        end

        #
        # @return {Bool}
        #
        def hosts_is_setup?
            File.exist? "#{@opts[:site_location]}/vvv-hosts"
        end

        #
        # @return {Bool}
        #
        def database_is_setup?
            File.readlines(File.expand_path("#{@environment.vvv_path}/database/init-custom.sql")).grep(/(# Begin '#{@opts[:site_name]}')/m).any?
        end

        #
        # @return {Bool}
        #
        def nginx_is_setup?
            File.exist? "#{@opts[:site_location]}/vvv-nginx.conf"
        end

        #
        # @return {Bool}
        #
        def wordpress_is_setup?
            File.exist? File.expand_path("#{@opts[:site_location]}/app")
        end

        #
        # @return {Bool}
        #
        def synced_folder_is_setup?
            File.readlines(File.expand_path("#{@environment.vvv_path}/Vagrantfile")).grep(/(# Begin '#{@opts[:site_name]}')/m).any?
        end

        #
        # @return {Bool}
        #
        def repo_is_setup?
            File.exist? File.expand_path("#{@opts[:site_location]}/.git")
        end

        #
        # @return {Bool}
        #
        def env_is_setup?
            File.exist? File.expand_path("#{@opts[:site_location]}/.env.development")
        end

        #
        # @return {Bool}
        #
        def wpcli_is_setup?
            File.exist? File.expand_path("#{@opts[:site_location]}/wp-cli.local.yml")
        end

        #
        # @return {Bool}
        #
        def using_repo?
            !!@opts[:site_repository]
        end
    end
end
