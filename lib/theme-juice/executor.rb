# encoding: UTF-8

module ThemeJuice
    module Executor
        class << self
            include ::Thor::Actions
            include ::Thor::Shell

            ###
            # Run installation from config
            #
            # @param {String} config_path (nil)
            #
            # @return {Void}
            ###
            def install(config_path = nil)
                config_path ||= File.expand_path(Dir.pwd)

                use_config config_path

                @config["install"].each do |command|
                    run ["cd #{config_path}", command], false
                end
            end

            ###
            # Run subcommand from config
            #
            # @param {String} subcommand
            # @param {String} commands
            #
            # @return {Void}
            ###
            def subcommand(subcommand, commands)
                config_path = File.expand_path(Dir.pwd)

                use_config config_path

                if @config[subcommand]
                    run ["#{@config[subcommand]} #{commands}"], false
                else
                    ::ThemeJuice::UI.error "Unable to find '#{subcommand}' command in '#{config_path}/tj-config.yml'. Aborting mission."
                end
            end

            ###
            # Set up local development environment and site
            #
            # @param {Hash} opts
            #
            # @return {Void}
            ###
            def create(opts)
                @opts = opts

                ::ThemeJuice::UI.notice "Running setup for '#{@opts[:site_name]}'..."

                unless project_dir_is_setup?
                    setup_project_dir
                end

                unless wordpress_is_setup?
                    setup_wordpress
                end

                if config_is_setup? @opts[:site_location]
                    use_config @opts[:site_location]

                    install_theme_dependencies
                end

                unless vvv_is_setup?
                    setup_vvv
                end

                unless wildcard_subdomains_is_setup?
                    setup_wildcard_subdomains
                end

                unless hosts_is_setup?
                    setup_hosts
                end

                unless database_is_setup?
                    setup_database
                end

                unless nginx_is_setup?
                    setup_nginx
                end

                unless dev_site_is_setup?
                    setup_dev_site
                end

                unless env_is_setup?
                    setup_env
                end

                unless synced_folder_is_setup?
                    setup_synced_folder
                end

                unless wpcli_is_setup?
                    setup_wpcli
                end

                if @opts[:repository]
                    setup_repo
                end

                if setup_was_successful?
                    ::ThemeJuice::UI.success "Setup complete!"
                    ::ThemeJuice::UI.speak "In order to finish creating your site, you need to provision Vagrant. Do it now? (y/N)", {
                        color: [:black, :on_blue],
                        icon: :restart,
                        row: true
                    }

                    if ::ThemeJuice::UI.agree? "", { simple: true }
                        ::ThemeJuice::UI.speak "Restarting VVV...", {
                            color: :yellow,
                            icon: :general
                        }

                        if restart_vagrant
                            ::ThemeJuice::UI.success "Success!"

                            # Output setup info
                            ::ThemeJuice::UI.list "Your settings :", :blue, [
                                "Site name: #{@opts[:site_name]}",
                                "Site location: #{@opts[:site_location]}",
                                "Starter theme: #{@opts[:starter_theme]}",
                                "Development location: #{@opts[:dev_location]}",
                                "Development url: http://#{@opts[:dev_url]}",
                                "Initialized repository: #{@opts[:repository]}",
                                "Database host: #{@opts[:db_host]}",
                                "Database name: #{@opts[:db_name]}",
                                "Database username: #{@opts[:db_user]}",
                                "Database password: #{@opts[:db_pass]}"
                            ]
                        end
                    else
                        ::ThemeJuice::UI.notice "Remember, Vagrant needs to be provisioned before you can use your new site. Exiting..."
                        exit
                    end
                else
                    ::ThemeJuice::UI.error "Setup failed. Running cleanup..." do
                        delete @opts[:site_name], false
                    end
                end
            end

            ###
            # Remove all traces of site from Vagrant
            #
            # @param {String} site
            # @param {Bool}   restart
            #
            # @return {Void}
            ###
            def delete(site, restart)

                ###
                # @TODO This is a really hacky way to remove the theme. Eventually,
                #   I'd like to handle state within a config file.
                ###
                @opts = {
                    site_name: site,
                    dev_location: File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/www/tj-#{site}")
                }

                if dev_site_is_setup?
                    remove_dev_site
                else
                    ::ThemeJuice::UI.error "Site '#{@opts[:site_name]}' does not exist."
                end

                if database_is_setup?
                    remove_database
                end

                if synced_folder_is_setup?
                    remove_synced_folder
                end

                if removal_was_successful?
                    ::ThemeJuice::UI.success "Site '#{@opts[:site_name]}' successfully removed!"

                    if restart
                        ::ThemeJuice::UI.speak "Restarting VVV...", {
                            color: :yellow,
                            icon: :general
                        }

                        restart_vagrant
                    end
                else
                    ::ThemeJuice::UI.error "'#{@opts[:site_name]}' could not be fully be removed."
                end
            end

            ###
            # List all development sites
            #
            # @return {Array}
            ###
            def list
                sites = []

                Dir.glob(File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/www/*")).each do |f|
                    sites << File.basename(f).gsub(/(tj-)/, "") if File.directory?(f) && f.include?("tj-")
                end

                if sites.empty?
                    ::ThemeJuice::UI.speak "Nothing to list. Why haven't you created a site yet?", {
                        color: :yellow,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.list "Your sites :", :green, sites
                end

                sites
            end

            private

            ###
            # Run system commands
            #
            # @param {Array} commands
            #   Array of commands to run
            # @param {Bool}  silent   (true)
            #   Silence all output from command
            #
            # @return {Void}
            ###
            def run(commands = [], silent = true)
                commands.map! { |cmd| cmd.to_s + " > /dev/null 2>&1" } if silent
                system commands.join "&&"
            end

            ###
            # Verify config is properly setup, set global var
            #
            # @param {String} config_path
            #
            # @return {Void}
            ###
            def use_config(config_path)

                if config_is_setup? config_path
                    @config = YAML.load_file "#{config_path}/tj-config.yml"
                else
                    ::ThemeJuice::UI.notice "Unable to find 'tj-config.yml' file in '#{config_path}'."

                    if ::ThemeJuice::UI.agree? "Would you like to create one?"

                        setup_config(config_path)

                        if config_is_setup? config_path
                            ::ThemeJuice::UI.notice "Please re-run the last command to continue."
                            exit
                        else
                            exit 1
                        end
                    else
                        ::ThemeJuice::UI.error "A config file is needed to continue. Aborting mission."
                    end
                end
            end

            ###
            # Restart Vagrant
            #
            # @note Normally a simple 'vagrant reload' would work, but Landrush requires
            #   a 'vagrant up' to be fired for it to set up the DNS correctly.
            #
            # @return {Void}
            ###
            def restart_vagrant
                run [
                    "cd #{::ThemeJuice::Utilities.vvv_path}",
                    "vagrant halt",
                    "vagrant up --provision",
                ], false
            end

            ###
            # @return {Bool}
            ###
            def setup_was_successful?
                vvv_is_setup? and dev_site_is_setup? and hosts_is_setup? and database_is_setup? and nginx_is_setup?
            end

            ###
            # @return {Bool}
            ###
            def removal_was_successful?
                !setup_was_successful?
            end

            ###
            # @return {Bool}
            ###
            def project_dir_is_setup?
                Dir.exist? "#{@opts[:site_location]}"
            end

            ###
            # @return {Bool}
            ###
            def config_is_setup?(config_path)
                File.exist? "#{config_path}/tj-config.yml"
            end

            ###
            # @return {Bool}
            ###
            def vvv_is_setup?
                File.exist? File.expand_path(::ThemeJuice::Utilities.vvv_path)
            end

            ###
            # @return {Bool}
            ###
            def wildcard_subdomains_is_setup?
                File.readlines(File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/Vagrantfile")).grep(/(config.landrush.enabled = true)/m).any?
            end

            ###
            # @return {Bool}
            ###
            def dev_site_is_setup?
                File.exist? "#{@opts[:dev_location]}"
            end

            ###
            # @return {Bool}
            ###
            def hosts_is_setup?
                File.exist? "#{@opts[:site_location]}/vvv-hosts"
            end

            ###
            # @return {Bool}
            ###
            def database_is_setup?
                File.readlines(File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/database/init-custom.sql")).grep(/(### Begin '#{@opts[:site_name]}')/m).any?
            end

            ###
            # @return {Bool}
            ###
            def nginx_is_setup?
                File.exist? "#{@opts[:site_location]}/vvv-nginx.conf"
            end

            ###
            # @return {Bool}
            ###
            def wordpress_is_setup?
                File.exist? File.expand_path("#{@opts[:site_location]}/app")
            end

            ###
            # @return {Bool}
            ###
            def synced_folder_is_setup?
                File.readlines(File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/Vagrantfile")).grep(/(### Begin '#{@opts[:site_name]}')/m).any?
            end

            ###
            # @return {Bool}
            ###
            def repo_is_setup?
                File.exist? File.expand_path("#{@opts[:site_location]}/.git")
            end

            ###
            # @return {Bool}
            ###
            def env_is_setup?
                File.exist? File.expand_path("#{@opts[:site_location]}/.env.development")
            end

            ###
            # @return {Bool}
            ###
            def wpcli_is_setup?
                File.exist? File.expand_path("#{@opts[:site_location]}/wp-cli.local.yml")
            end

            ###
            # Install Vagrant plugins and clone VVV
            #
            # @return {Void}
            ###
            def setup_vvv
                ::ThemeJuice::UI.speak "Installing VVV into '#{File.expand_path("#{::ThemeJuice::Utilities.vvv_path}")}'...", {
                    color: :yellow,
                    icon: :general
                }

                run [
                    "vagrant plugin install vagrant-hostsupdater",
                    "vagrant plugin install vagrant-triggers",
                    "vagrant plugin install landrush",
                    "git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git #{::ThemeJuice::Utilities.vvv_path}",
                    "cd #{::ThemeJuice::Utilities.vvv_path}/database && touch init-custom.sql"
                ]
            end

            ###
            # Ensure project directory structure
            #
            # @return {Void}
            ###
            def setup_project_dir
                ::ThemeJuice::UI.speak "Creating project directory tree in '#{@opts[:site_location]}'...", {
                    color: :yellow,
                    icon: :general
                }

                run ["mkdir -p #{@opts[:site_location]}"]
            end

            ###
            # Enable Landrush for wildcard subdomains
            #
            # This will write a Landrush activation block to the global Vagrantfile
            #   if one does not already exist.
            #
            # @return {Void}
            ###
            def setup_wildcard_subdomains
                ::ThemeJuice::UI.speak "Setting up wildcard subdomains...", {
                    color: :yellow,
                    icon: :general
                }

                open File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/Vagrantfile"), "a+" do |file|
                    file.puts "\n"
                    file.puts "###"
                    file.puts "# Enable wildcard subdomains"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "Vagrant.configure('2') do |config|"
                    file.puts "\tconfig.landrush.enabled = true"
                    file.puts "\tconfig.landrush.tld = 'dev'"
                    file.puts "end"
                    file.puts "\n"
                end
            end

            ###
            # Create a new directory for site that will be symlinked with the local install
            #
            # @return {Void}
            ###
            def setup_dev_site
                ::ThemeJuice::UI.speak "Setting up new development site at '#{@opts[:dev_location]}'...", {
                    color: :yellow,
                    icon: :general
                }

                run [
                    "cd #{::ThemeJuice::Utilities.vvv_path}/www",
                    "mkdir tj-#{@opts[:site_name]}",
                ]
            end

            ###
            # Create tj-config.yml file for theme settings
            #
            # @param {String} config_path
            #
            # @return {Void}
            ###
            def setup_config(config_path)
                watch   = ::ThemeJuice::UI.prompt "Watch command to use",             indent: 2, default: "bundle exec guard"
                server  = ::ThemeJuice::UI.prompt "Deployment command to use",        indent: 2, default: "bundle exec cap"
                vendor  = ::ThemeJuice::UI.prompt "Vendor command to use",            indent: 2, default: "composer"
                install = ::ThemeJuice::UI.prompt "Commands to run on theme install", indent: 2, default: "composer install"

                File.open "#{config_path}/tj-config.yml", "w" do |file|
                    file.puts "watch: #{watch}"
                    file.puts "server: #{server}"
                    file.puts "vendor: #{vendor}"
                    file.puts "install:"
                    file.puts "\s\s\s\s- #{install}"
                end

                if config_is_setup? config_path
                    ::ThemeJuice::UI.speak "Successfully added 'tj-config.yml' file.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not create 'tj-config.yml' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Create vvv-hosts file
            #
            # @return {Void}
            ###
            def setup_hosts
                File.open "#{@opts[:site_location]}/vvv-hosts", "w" do |file|
                    file.puts @opts[:dev_url]
                end

                if hosts_is_setup?
                    ::ThemeJuice::UI.speak "Successfully added 'vvv-hosts' file.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not create 'vvv-hosts' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Add database block to init-custom.sql, create if not exists
            #
            # @return {Void}
            ###
            def setup_database
                File.open File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/database/init-custom.sql"), "a+" do |file|
                    file.puts "### Begin '#{@opts[:site_name]}'"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "CREATE DATABASE IF NOT EXISTS `#{@opts[:db_name]}`;"
                    file.puts "GRANT ALL PRIVILEGES ON `#{@opts[:db_name]}`.* TO '#{@opts[:db_user]}'@'localhost' IDENTIFIED BY '#{@opts[:db_pass]}';"
                    file.puts "### End '#{@opts[:site_name]}'"
                    file.puts "\n"
                end

                if database_is_setup?
                    ::ThemeJuice::UI.speak "Successfully added database to 'init-custom.sql'.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not add database info for '#{@opts[:site_name]}' to 'init-custom.sql'. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Create vvv-nginx.conf file for local development site
            #
            # @return {Void}
            ###
            def setup_nginx
                File.open "#{@opts[:site_location]}/vvv-nginx.conf", "w" do |file|
                    file.puts "server {"
                    file.puts "\tlisten 80;"
                    file.puts "\tserver_name .#{@opts[:dev_url]};"
                    file.puts "\troot {vvv_path_to_folder};"
                    file.puts "\tinclude /etc/nginx/nginx-wp-common.conf;"
                    file.puts "}"
                end

                if nginx_is_setup?
                    ::ThemeJuice::UI.speak "Successfully added 'vvv-nginx.conf' file.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not create 'vvv-nginx.conf' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Create Dotenv environment file
            #
            # @return {Void}
            ###
            def setup_env
                File.open "#{@opts[:site_location]}/.env.development", "w" do |file|
                    file.puts "DB_NAME=#{@opts[:db_name]}"
                    file.puts "DB_USER=#{@opts[:db_user]}"
                    file.puts "DB_PASSWORD=#{@opts[:db_pass]}"
                    file.puts "DB_HOST=#{@opts[:db_host]}"
                    file.puts "WP_HOME=http://#{@opts[:dev_url]}"
                    file.puts "WP_SITEURL=http://#{@opts[:dev_url]}/wp"
                end

                if env_is_setup?
                    ::ThemeJuice::UI.speak "Successfully added '.env.development' file.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not create '.env.development' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Setup WordPress
            #
            # Clones starter theme into site location
            #
            # @return {Void}
            ###
            def setup_wordpress
                ::ThemeJuice::UI.speak "Setting up WordPress...", {
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

            ###
            # Install dependencies for starter theme
            #
            # @return {Void}
            ###
            def install_theme_dependencies
                ::ThemeJuice::UI.speak "Installing theme dependencies...", {
                    color: :yellow,
                    icon: :general
                }

                @config["install"].each do |command|
                    run ["cd #{@opts[:site_location]}", command], false
                end
            end

            ###
            # Add synced folder block to Vagrantfile
            #
            # @return {Void}
            ###
            def setup_synced_folder
                ::ThemeJuice::UI.speak "Syncing host theme directory '#{@opts[:site_location]}' with VM theme directory '/srv/www/tj-#{@opts[:site_name]}'...", {
                    color: :yellow,
                    icon: :general
                }

                open File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/Vagrantfile"), "a+" do |file|
                    file.puts "### Begin '#{@opts[:site_name]}'"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "Vagrant.configure('2') do |config|"
                    file.puts "\tconfig.vm.synced_folder '#{@opts[:site_location]}', '/srv/www/tj-#{@opts[:site_name]}', mount_options: ['dmode=777','fmode=777']"
                    file.puts "\tconfig.landrush.host '#{@opts[:dev_url]}', '192.168.50.4'"
                    file.puts "end"
                    file.puts "### End '#{@opts[:site_name]}'"
                    file.puts "\n"
                end
            end

            ###
            # Initialize Git repo, add remote, initial commit
            #
            # @return {Void}
            ###
            def setup_repo
                ::ThemeJuice::UI.speak "Setting up Git repository at '#{@opts[:repository]}'...", {
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
            ###
            def setup_wpcli
                File.open "#{@opts[:site_location]}/wp-cli.local.yml", "a+" do |file|
                    file.puts "require:"
                    file.puts "\t- vendor/autoload.php"
                    file.puts "ssh:"
                    file.puts "\tvagrant:"
                    file.puts "\t\turl: #{@opts[:dev_url]}"
                    file.puts "\t\tpath: /srv/www/tj-#{@opts[:site_name]}"
                    file.puts "\t\tcmd: cd #{::ThemeJuice::Utilities.vvv_path} && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%"
                    file.puts "\n"
                end

                if wpcli_is_setup?
                    ::ThemeJuice::UI.speak "Successfully added ssh settings to 'wp-cli.local.yml' file.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Could not create 'wp-cli.local.yml' file. Make sure you have write capabilities to '#{@opts[:site_location]}'."
                end
            end

            ###
            # Remove all theme files from Vagrant directory
            #
            # @return {Void}
            ###
            def remove_dev_site

                unless Dir.entries("#{::ThemeJuice::Utilities.vvv_path}").include? "www"
                    say " ↑ Cannot load VVV path. Aborting mission before something bad happens.".ljust(terminal_width), [:white, :on_red]
                    exit 1
                end

                if run ["rm -rf #{@opts[:dev_location]}"]
                    ::ThemeJuice::UI.speak "VVV installation for '#{@opts[:site_name]}' successfully removed.", {
                        color: :green,
                        icon: :general
                    }
                else
                    ::ThemeJuice::UI.error "Theme '#{@opts[:site_name]}' could not be removed. Make sure you have write capabilities to '#{@opts[:dev_location]}'."
                end
            end

            ###
            # Remove database block from init-custom.sql
            #
            # @return {Void}
            ###
            def remove_database
                if remove_traces_from_file "#{::ThemeJuice::Utilities.vvv_path}/database/init-custom.sql"
                    ::ThemeJuice::UI.speak "Database for '#{@opts[:site_name]}' successfully removed.", {
                        color: :yellow,
                        icon: :general
                    }
                end
            end

            ###
            # Remove synced folder block from Vagrantfile
            #
            # @return {Void}
            ###
            def remove_synced_folder
                if remove_traces_from_file "#{::ThemeJuice::Utilities.vvv_path}/Vagrantfile"
                    ::ThemeJuice::UI.speak "Synced folders for '#{@opts[:site_name]}' successfully removed.", {
                        color: :yellow,
                        icon: :general
                    }
                end
            end

            ###
            # Remove all traces of auto-generated content from file
            #
            # @param {String} input_file
            #
            # @return {Void}
            ###
            def remove_traces_from_file(input_file)
                begin
                    # Create new tempfile
                    output_file = Tempfile.new File.basename(input_file)
                    # Copy over contents of actual file to tempfile
                    open File.expand_path(input_file), "rb" do |file|
                        # Remove traces of theme from contents
                        output_file.write "#{file.read}".gsub(/(### Begin '#{@opts[:site_name]}')(.*?)(### End '#{@opts[:site_name]}')\n+/m, "")
                    end
                    # Move temp file to actual file location
                    FileUtils.mv output_file, File.expand_path(input_file)
                rescue LoadError => err
                    say " ↑ #{err}".ljust(terminal_width), [:white, :on_red]
                    exit 1
                ensure
                    # Make sure that the tempfile closes and is cleaned up, regardless of errors
                    output_file.close
                    output_file.unlink
                end
            end
        end
    end
end
