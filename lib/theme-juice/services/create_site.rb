# encoding: UTF-8

module ThemeJuice
    class Service::CreateSite < ::ThemeJuice::Service

        #
        # @param {Hash} opts
        #
        def initialize(opts = {})
            opts = ::ThemeJuice::Interaction::CreateSiteOptions.new.setup_site_options(opts)

            super
        end

        #
        # Set up local development environment and site
        #
        # @return {Void}
        #
        def create
            @interaction.notice "Running setup for '#{@opts[:site_name]}'..."

            steps = {
                setup_project_dir:          :project_dir_is_setup?,
                setup_wordpress:            :wordpress_is_setup?,
                install_theme_dependencies: :config_is_setup?,
                setup_vvv:                  :vvv_is_setup?,
                setup_wildcard_subdomains:  :wildcard_subdomains_is_setup?,
                setup_hosts:                :hosts_is_setup?,
                setup_database:             :database_is_setup?,
                setup_nginx:                :nginx_is_setup?,
                setup_dev_site:             :dev_site_is_setup?,
                setup_env:                  :env_is_setup?,
                setup_synced_folder:        :synced_is_setup?,
                setup_wpcli:                :wpcli_is_setup?,
                setup_repo:                 :using_repo?,
            }

            steps.each do |action, condition|
                send "#{action}" unless send "#{condition}"
            end

            if setup_was_successful?
                @interaction.success "Setup complete!"
                @interaction.speak "In order to finish creating your site, you need to provision Vagrant. Do it now? (y/N)", {
                    color: [:black, :on_blue],
                    icon: :restart,
                    row: true
                }

                if @interaction.agree? "", { simple: true }

                    if restart_vagrant
                        @interaction.success "Success!"

                        # Output setup info
                        @interaction.list "Your settings :", :blue, [
                            "Site name: #{@opts[:site_name]}",
                            "Site location: #{@opts[:site_location]}",
                            "Starter theme: #{@opts[:site_starter_theme]}",
                            "Development location: #{@opts[:site_dev_location]}",
                            "Development url: http://#{@opts[:site_dev_url]}",
                            "Initialized repository: #{@opts[:site_repository]}",
                            "Database host: #{@opts[:site_db_host]}",
                            "Database name: #{@opts[:site_db_name]}",
                            "Database username: #{@opts[:site_db_user]}",
                            "Database password: #{@opts[:site_db_pass]}"
                        ]
                    end

                    unless OS.windows?
                        @interaction.notice "Do you want to open up your new site 'http://#{@opts[:dev_url]}' now? (y/N)"

                        if @interaction.agree? "", { color: :yellow, simple: true }
                            run ["open http://#{@opts[:dev_url]}"]
                        end
                    end
                else
                    @interaction.notice "Remember, Vagrant needs to be provisioned before you can use your new site. Exiting..."
                    exit
                end
            else
                @interaction.error "Setup failed. Running cleanup..." do
                    ::ThemeJuice::Service::Delete.new({ site_name: @opts[:site_name], restart: false }).delete
                end
            end
        end

        private

        #
        # Install Vagrant plugins and clone VVV
        #
        # @return {Void}
        #
        def setup_vvv
            @interaction.speak "Installing VVV...", {
                color: :yellow,
                icon: :general
            }

            run [
                "vagrant plugin install vagrant-hostsupdater",
                "vagrant plugin install vagrant-triggers",
                "vagrant plugin install landrush",
                "git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git #{@environment.vvv_path}",
                "touch #{@environment.vvv_path}/database/init-custom.sql"
            ]
        end

        #
        # Ensure project directory structure
        #
        # @return {Void}
        #
        def setup_project_dir
            @interaction.speak "Creating project directory tree...", {
                color: :yellow,
                icon: :general
            }

            run ["mkdir -p #{@opts[:site_location]}"]
        end

        #
        # Enable Landrush for wildcard subdomains
        #
        # This will write a Landrush activation block to the global Vagrantfile
        #   if one does not already exist.
        #
        # @return {Void}
        #
        def setup_wildcard_subdomains
            @interaction.speak "Setting up wildcard subdomains...", {
                color: :yellow,
                icon: :general
            }

            File.open File.expand_path("#{@environment.vvv_path}/Vagrantfile"), "ab+" do |file|
                file.puts "\n"
                file.puts "#"
                file.puts "# Enable wildcard subdomains"
                file.puts "#"
                file.puts "# This block is automatically generated by Theme Juice. Do not edit."
                file.puts "#"
                file.puts "Vagrant.configure('2') do |config|"
                file.puts "\tconfig.landrush.enabled = true"
                file.puts "\tconfig.landrush.tld = 'dev'"
                file.puts "end"
                file.puts "\n"
            end
        end

        #
        # Create a new directory for site that will be symlinked with the local install
        #
        # @return {Void}
        #
        def setup_dev_site
            @interaction.speak "Setting up new site in VM...", {
                color: :yellow,
                icon: :general
            }

            run [
                "cd #{@environment.vvv_path}/www",
                "mkdir tj-#{@opts[:site_name]}",
            ]
        end

        #
        # Create tj.yml file for theme settings
        #
        # @return {Void}
        #
        def setup_config
            @interaction.speak "Creating config...", {
                color: :yellow,
                icon: :general
            }

            watch   = @interaction.prompt "Watch command to use",                               indent: 2, default: "bundle exec guard"
            server  = @interaction.prompt "Deployment command to use",                          indent: 2, default: "bundle exec cap"
            vendor  = @interaction.prompt "Vendor command to use",                              indent: 2, default: "composer"
            install = @interaction.prompt "Commands to run on theme install (comma-delimited)", indent: 2, default: "composer install"

            File.open "#{@config_path}/tj.yml", "wb" do |file|
                file.puts "commands:"
                file.puts "\s\swatch: #{watch}"
                file.puts "\s\sserver: #{server}"
                file.puts "\s\svendor: #{vendor}"
                file.puts "\s\sinstall:"
                install.split(",").map!(&:strip).each do |command|
                    file.puts "\s\s\s\s- #{command}"
                end
            end

            unless config_is_setup?
                @interaction.error "Could not create 'tj.yml' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
            end
        end

        #
        # Create vvv-hosts file
        #
        # @return {Void}
        #
        def setup_hosts
            @interaction.speak "Setting up hosts...", {
                color: :yellow,
                icon: :general
            }

            File.open "#{@opts[:site_location]}/vvv-hosts", "wb" do |file|
                file.puts @opts[:dev_url]
            end

            unless hosts_is_setup?
                @interaction.error "Could not create 'vvv-hosts' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
            end
        end

        #
        # Add database block to init-custom.sql, create if not exists
        #
        # @return {Void}
        #
        def setup_database
            @interaction.speak "Setting up database...", {
                color: :yellow,
                icon: :general
            }

            File.open File.expand_path("#{@environment.vvv_path}/database/init-custom.sql"), "ab+" do |file|
                file.puts "# Begin '#{@opts[:site_name]}'"
                file.puts "#"
                file.puts "# This block is automatically generated by Theme Juice. Do not edit."
                file.puts "#"
                file.puts "CREATE DATABASE IF NOT EXISTS `#{@opts[:db_name]}`;"
                file.puts "GRANT ALL PRIVILEGES ON `#{@opts[:db_name]}`.* TO '#{@opts[:db_user]}'@'localhost' IDENTIFIED BY '#{@opts[:db_pass]}';"
                file.puts "# End '#{@opts[:site_name]}'"
                file.puts "\n"
            end

            unless database_is_setup?
                @interaction.error "Could not add database info for '#{@opts[:site_name]}' to 'init-custom.sql'. Make sure you have write capabilities to '#{@environment.vvv_path}'."
            end
        end

        #
        # Create vvv-nginx.conf file for local development site
        #
        # @return {Void}
        #
        def setup_nginx
            @interaction.speak "Setting up nginx...", {
                color: :yellow,
                icon: :general
            }

            File.open "#{@opts[:site_location]}/vvv-nginx.conf", "wb" do |file|
                file.puts "server {"
                file.puts "\tlisten 80;"
                file.puts "\tserver_name .#{@opts[:dev_url]};"
                file.puts "\troot {vvv_path_to_folder};"
                file.puts "\tinclude /etc/nginx/nginx-wp-common.conf;"
                file.puts "}"
            end

            unless nginx_is_setup?
                @interaction.error "Could not create 'vvv-nginx.conf' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
            end
        end

        #
        # Create Dotenv environment file
        #
        # @return {Void}
        #
        def setup_env
            @interaction.speak "Setting up environment...", {
                color: :yellow,
                icon: :general
            }

            File.open "#{@opts[:site_location]}/.env.development", "wb" do |file|
                file.puts "DB_NAME=#{@opts[:db_name]}"
                file.puts "DB_USER=#{@opts[:db_user]}"
                file.puts "DB_PASSWORD=#{@opts[:db_pass]}"
                file.puts "DB_HOST=#{@opts[:db_host]}"
                file.puts "WP_HOME=http://#{@opts[:dev_url]}"
                file.puts "WP_SITEURL=http://#{@opts[:dev_url]}/wp"
            end

            unless env_is_setup?
                @interaction.error "Could not create '.env.development' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
            end
        end

        #
        # Setup WordPress
        #
        # Clones starter theme into site location
        #
        # @return {Void}
        #
        def setup_wordpress
            @interaction.speak "Setting up WordPress...", {
                color: :yellow,
                icon: :general
            }

            unless @opts[:bare_setup]
                run [
                    "cd #{@opts[:site_location]}",
                    "git clone --depth 1 #{@opts[:starter_theme]} .",
                ]
            end
        end

        #
        # Install dependencies for starter theme
        #
        # @return {Void}
        #
        def install_theme_dependencies
            use_config

            @interaction.speak "Installing theme dependencies...", {
                color: :yellow,
                icon: :general
            }

            @config["commands"]["install"].each do |command|
                run ["cd #{@opts[:site_location]}", command], false
            end
        end

        #
        # Add synced folder block to Vagrantfile
        #
        # @return {Void}
        #
        def setup_synced_folder
            @interaction.speak "Syncing host theme with VM...", {
                color: :yellow,
                icon: :general
            }

            File.open File.expand_path("#{@environment.vvv_path}/Vagrantfile"), "ab+" do |file|
                file.puts "# Begin '#{@opts[:site_name]}'"
                file.puts "#"
                file.puts "# This block is automatically generated by Theme Juice. Do not edit."
                file.puts "#"
                file.puts "Vagrant.configure('2') do |config|"
                file.puts "\tconfig.vm.synced_folder '#{@opts[:site_location]}', '/srv/www/tj-#{@opts[:site_name]}', mount_options: ['dmode=777','fmode=777']"
                file.puts "\tconfig.landrush.host '#{@opts[:dev_url]}', '192.168.50.4'"
                file.puts "end"
                file.puts "# End '#{@opts[:site_name]}'"
                file.puts "\n"
            end

            unless synced_folder_is_setup?
                @interaction.error "Could not sync folders for '#{@opts[:site_name]}' in 'Vagrantfile'. Make sure you have write capabilities to '#{@environment.vvv_path}'."
            end
        end

        #
        # Initialize Git repo, add remote, initial commit
        #
        # @return {Void}
        #
        def setup_repo
            @interaction.speak "Setting up Git repository...", {
                color: :yellow,
                icon: :general
            }

            if repo_is_setup?
                run [
                    "cd #{@opts[:site_location]}",
                    "rm -rf .git",
                ]
            end

            run [
                "cd #{@opts[:site_location]}",
                "git init",
                "git remote add origin #{@opts[:repository]}",
            ]
        end

        ##
        # Add wp-cli-ssh block to wp-cli.yml
        #
        # @return {Void}
        #
        def setup_wpcli
            @interaction.speak "Setting up WP-CLI...", {
                color: :yellow,
                icon: :general
            }

            File.open "#{@opts[:site_location]}/wp-cli.local.yml", "ab+" do |file|
                file.puts "require:"
                file.puts "\t- vendor/autoload.php"
                file.puts "ssh:"
                file.puts "\tvagrant:"
                file.puts "\t\turl: #{@opts[:dev_url]}"
                file.puts "\t\tpath: /srv/www/tj-#{@opts[:site_name]}"
                file.puts "\t\tcmd: cd #{@environment.vvv_path} && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%"
                file.puts "\n"
            end

            unless wpcli_is_setup?
                @interaction.error "Could not create 'wp-cli.local.yml' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
            end
        end
    end
end
