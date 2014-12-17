module ThemeJuice
    module Scaffold
        class << self
            include ::Thor::Actions
            include ::Thor::Shell

            ###
            # Set up local development environment
            #
            # @return {Void}
            ###
            def init
                say "Initializing development environment...", :yellow

                if vvv_is_setup?
                    say "Development environment is already set up. Aborting mission.", :red
                else
                    say "Setup successful!", :green if setup_vvv
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

                say "Running setup for '#{@opts[:site_name]}'...", :yellow

                unless wordpress_is_setup?
                    setup_wordpress
                end

                unless vvv_is_setup?
                    setup_vvv
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
                    say "Restarting VVV...", :yellow

                    if restart_vagrant

                        # Get smiley ASCII art
                        smiley = File.read(File.expand_path("../ascii/smiley.txt", __FILE__))

                        # Output welcome message
                        say "\n"
                        say smiley, :yellow
                        say "\n"
                        say "Success!".center(48), :green
                        say "\n\n"

                        # Output setup info
                        say "Here's your installation info:", :yellow
                        say "Site name: #{@opts[:site_name]}", :blue
                        say "Site location: #{@opts[:site_location]}", :blue
                        say "Starter theme: #{@opts[:starter_theme]}", :blue
                        say "Development location: #{@opts[:dev_location]}", :blue
                        say "Development url: http://#{@opts[:dev_url]}", :blue
                        say "Initialized repository: #{@opts[:repository]}", :blue
                        say "Database host: #{@opts[:db_host]}", :blue
                        say "Database name: #{@opts[:db_name]}", :blue
                        say "Database username: #{@opts[:db_user]}", :blue
                        say "Database password: #{@opts[:db_pass]}", :blue
                    end
                else
                    say "Setup failed. Running cleanup...", :red
                    delete @opts[:site_name], false
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
                # @TODO - This is a really hacky way to remove the theme.
                #   Eventually I'd like to handle state.
                ###
                @opts = {
                    site_name: site,
                    dev_location: File.expand_path("~/vagrant/www/tj-#{site}")
                }

                if dev_site_is_setup?
                    remove_dev_site
                else
                    say "Site '#{@opts[:site_name]}' does not exist.", :red
                    exit 1
                end

                if database_is_setup?
                    remove_database
                end

                if synced_folder_is_setup?
                    remove_synced_folder
                end

                if removal_was_successful?
                    say "Site '#{@opts[:site_name]}' successfully removed!", :green

                    if restart
                        say "Restarting VVV...", :yellow
                        restart_vagrant
                    end
                else
                    say "Site '#{@opts[:site_name]}' could not be fully be removed.", :red
                end
            end

            ###
            # List all development sites
            #
            # @return {Array}
            ###
            def list
                sites = []

                Dir.glob(File.expand_path("~/vagrant/www/*")).each do |f|
                    sites << File.basename(f).gsub(/(tj-)/, "") if File.directory?(f) && f.include?("tj-")
                end

                if sites.empty?
                    say "Nothing to list. Create a new site!", :yellow
                else
                    i = 0
                    # Output site to cli
                    sites.each { |site| i += 1; say "#{i}) #{site}", :green }
                end

                sites
            end

            private

            ###
            # Run system commands
            #
            # @param {Array} commands
            #    Array of commands to run
            # @param {Bool}  silent   (true)
            #    Silence all output from command
            #
            # @return {Void}
            ###
            def run(commands = [], silent = true)
                commands.map! { |cmd| cmd.to_s + " > /dev/null 2>&1" } if silent
                system commands.join "&&"
            end

            ###
            # Restart Vagrant
            #
            # @note
            # Normally a simple 'vagrant reload' would work, but Landrush requires a
            #   'vagrant up' to be fired for it to set up the DNS correctly.
            #
            # @return {Void}
            ###
            def restart_vagrant
                run [
                    "cd ~/vagrant",
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
            def vvv_is_setup?
                File.exists? File.expand_path("~/vagrant")
            end

            ###
            # @return {Bool}
            ###
            def dev_site_is_setup?
                File.exists? "#{@opts[:dev_location]}"
            end

            ###
            # @return {Bool}
            ###
            def hosts_is_setup?
                File.exists? "#{@opts[:site_location]}/vvv-hosts"
            end

            ###
            # @return {Bool}
            ###
            def database_is_setup?
                File.readlines(File.expand_path("~/vagrant/database/init-custom.sql")).grep(/(### Begin '#{@opts[:site_name]}')/m).any?
            end

            ###
            # @return {Bool}
            ###
            def nginx_is_setup?
                File.exists? "#{@opts[:site_location]}/vvv-nginx.conf"
            end

            ###
            # @return {Bool}
            ###
            def wordpress_is_setup?
                File.exists? File.expand_path("#{@opts[:site_location]}/app")
            end

            ###
            # @return {Bool}
            ###
            def synced_folder_is_setup?
                File.readlines(File.expand_path("~/vagrant/Vagrantfile")).grep(/(### Begin '#{@opts[:site_name]}')/m).any?
            end

            ###
            # @return {Bool}
            ###
            def repo_is_setup?
                File.exists? File.expand_path("#{@opts[:site_location]}/.git")
            end

            ###
            # @return {Bool}
            ###
            def env_is_setup?
                File.exists? File.expand_path("#{@opts[:site_location]}/.env.development")
            end

            ###
            # @return {Bool}
            ###
            def wpcli_is_setup?
                File.exists? File.expand_path("#{@opts[:site_location]}/wp-cli.local.yml")
            end

            ###
            # Install Vagrant plugins and clone VVV
            #
            # @return {Void}
            ###
            def setup_vvv
                say "Installing VVV into '#{File.expand_path("~/vagrant")}'...", :yellow
                run [
                    "vagrant plugin install vagrant-hostsupdater",
                    "vagrant plugin install vagrant-triggers",
                    "vagrant plugin install landrush",
                    "git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git ~/vagrant",
                    "cd ~/vagrant/database && touch init-custom.sql"
                ]

                setup_wildcard_subdomains
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
                say "Setting up wildcard subdomains...", :yellow
                open File.expand_path("~/vagrant/Vagrantfile"), "a+" do |file|
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
                say "Setting up new development site at '#{@opts[:dev_location]}'...", :yellow
                run [
                    "cd ~/vagrant/www",
                    "mkdir tj-#{@opts[:site_name]}",
                ]
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
                    say "Successfully added 'vvv-hosts' file.", :green
                else
                    say "Could not create 'vvv-hosts' file.", :red
                end
            end

            ###
            # Add database block to init-custom.sql, create if not exists
            #
            # @return {Void}
            ###
            def setup_database
                File.open File.expand_path("~/vagrant/database/init-custom.sql"), "a+" do |file|
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
                    say "Successfully added database to 'init-custom.sql'.", :green
                else
                    say "Could not add database info for '#{@opts[:site_name]}' to 'init-custom.sql'.", :red
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
                    say "Successfully added 'vvv-nginx.conf' file.", :green
                else
                    say "Could not create 'vvv-nginx.conf' file.", :red
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
                    say "Successfully added '.env.development' file.", :green
                else
                    say "Could not create '.env.development' file.", :red
                end
            end

            ###
            # Setup WordPress
            #
            # Clones starter theme into @opts[:site_location]
            #
            # @return {Void}
            ###
            def setup_wordpress
                say "Setting up WordPress...", :yellow

                if @opts[:bare_setup]

                    # Create theme dir
                    run [
                        "mkdir -p #{@opts[:site_location]}",
                    ]

                else

                    # Clone starter theme
                    run [
                        "mkdir -p #{@opts[:site_location]}",
                        "cd #{@opts[:site_location]}",
                        "git clone --depth 1 https://github.com/#{@opts[:starter_theme]}.git .",
                    ]

                    # Install composer dependencies
                    run [
                        "cd #{@opts[:site_location]}",
                        "composer install",
                    ], false

                end
            end

            ###
            # Add synced folder block to Vagrantfile
            #
            # @return {Void}
            ###
            def setup_synced_folder
                say "Syncing host theme directory '#{@opts[:site_location]}' with VM theme directory '/srv/www/tj-#{@opts[:site_name]}'...", :yellow

                open File.expand_path("~/vagrant/Vagrantfile"), "a+" do |file|
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
                say "Setting up Git repository at '#{@opts[:repository]}'...", :yellow

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
                    file.puts "\t\tcmd: cd ~/vagrant && vagrant ssh-config > /tmp/vagrant_ssh_config && ssh -q %pseudotty% -F /tmp/vagrant_ssh_config default %cmd%"
                    file.puts "\n"
                end

                if wpcli_is_setup?
                    say "Successfully added ssh settings to 'wp-cli.local.yml' file.", :green
                else
                    say "Could not create 'wp-cli.local.yml' file.", :red
                end
            end

            ###
            # Remove all theme files from Vagrant directory
            #
            # @return {Void}
            ###
            def remove_dev_site
                if run ["rm -rf #{@opts[:dev_location]}"]
                    say "VVV installation for '#{@opts[:site_name]}' successfully removed.", :yellow
                else
                    say "Theme '#{@opts[:site_name]}' could not be removed. Make sure you have write capabilities.", :red
                end
            end

            ###
            # Remove database block from init-custom.sql
            #
            # @return {Void}
            ###
            def remove_database
                if remove_traces_from_file "~/vagrant/database/init-custom.sql"
                    say "Database for '#{@opts[:site_name]}' successfully removed.", :yellow
                end
            end

            ###
            # Remove synced folder block from Vagrantfile
            #
            # @return {Void}
            ###
            def remove_synced_folder
                if remove_traces_from_file "~/vagrant/Vagrantfile"
                    say "Synced folders for '#{@opts[:site_name]}' successfully removed.", :yellow
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
                    say err, :red
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
