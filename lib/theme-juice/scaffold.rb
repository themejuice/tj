module ThemeJuice
    module Scaffold
        class << self

            ###
            # Set up local development environment
            #
            # @return {Void}
            ###
            def init
                ::ThemeJuice::warning "Initializing development environment..."

                if vvv_is_setup?
                    ::ThemeJuice::error "Development environment is already set up. Aborting mission."
                else
                    setup_vvv
                    ::ThemeJuice::success "Setup successful!"
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

                ::ThemeJuice::warning "Running setup for `#{@opts[:site_name]}`..."

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

                if @opts[:repository] != "none"
                    setup_repo
                end

                if setup_was_successful?
                    ::ThemeJuice::success "Setup successful!"
                    ::ThemeJuice::warning "Restarting VVV..."

                    if restart_vagrant
                        prompt_color = "blue"
                        ::ThemeJuice::message "Site name: #{@opts[:site_name]}", prompt_color
                        ::ThemeJuice::message "Site location: #{@opts[:site_location]}", prompt_color
                        ::ThemeJuice::message "Starter theme: #{@opts[:starter_theme]}", prompt_color
                        ::ThemeJuice::message "Development environment: #{@opts[:dev_location]}", prompt_color
                        ::ThemeJuice::message "Development url: http://#{@opts[:dev_url]}", prompt_color
                        ::ThemeJuice::message "Repository: #{@opts[:repository]}", prompt_color
                        ::ThemeJuice::message "Database host: #{@opts[:db_host]}", prompt_color
                        ::ThemeJuice::message "Database name: #{@opts[:db_name]}", prompt_color
                        ::ThemeJuice::message "Database username: #{@opts[:db_user]}", prompt_color
                        ::ThemeJuice::message "Database password: #{@opts[:db_pass]}", prompt_color
                    end
                else
                    ::ThemeJuice::error "Setup failed. Running cleanup..."
                    delete @opts[:site_name], false
                end
            end

            ###
            # Remove all traces of theme from Vagrant
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
                    :site_name => site,
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{site}")
                }

                if dev_site_is_setup?
                    ::ThemeJuice::warning "Removing site `#{@opts[:site_name]}`..."
                    remove_dev_site
                else
                    ::ThemeJuice::error "Site `#{@opts[:site_name]}` does not exist."
                    exit 1
                end

                if database_is_setup?
                    remove_database
                end

                if synced_folder_is_setup?
                    remove_synced_folder
                end

                if removal_was_successful?
                    ::ThemeJuice::success "Site `#{@opts[:site_name]}` successfully removed!"

                    unless restart.nil?
                        ::ThemeJuice::warning "Restarting VVV..."
                        restart_vagrant
                    end
                else
                    ::ThemeJuice::error "Site `#{@opts[:site_name]}` could not be fully be removed."
                end
            end

            ###
            # List all development sites
            #
            # @return {Array}
            ###
            def list
                sites = []

                Dir.glob(File.expand_path("~/vagrant/www/*")).each_with_index do |f, i|
                    if File.directory?(f) && f.include?("dev-")
                        # Get the site name
                        site = File.basename(f).gsub(/(dev-)/, "")
                        # Output site to cli
                        ::ThemeJuice::list site, i
                        # Save site to sites arr
                        sites << site
                    end
                end

                sites
            end

            private

            ###
            # Restart Vagrant
            #
            # @note
            # Normally a simple `vagrant reload` would work, but Landrush requires a
            #   `vagrant up` to be fired for it to set up the DNS correctly.
            #
            # @return {Void}
            ###
            def restart_vagrant
                system [
                    "cd ~/vagrant",
                    "vagrant halt",
                    "vagrant up --provision"
                ].join " && "
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
                File.readlines(File.expand_path "~/vagrant/database/init-custom.sql").grep(/(### Begin `#{@opts[:site_name]}`)/m).any?
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
                File.readlines(File.expand_path "~/vagrant/Vagrantfile").grep(/(### Begin `#{@opts[:site_name]}`)/m).any?
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
            # Install plugins and clone VVV
            #
            # @return {Void}
            ###
            def setup_vvv
                ::ThemeJuice::warning "Installing VVV into `#{File.expand_path "~/vagrant"}`."
                system [
                    "vagrant plugin install vagrant-hostsupdater",
                    "vagrant plugin install vagrant-triggers",
                    "vagrant plugin install landrush",
                    "git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git ~/vagrant",
                ].join " && "

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
                ::ThemeJuice::warning "Setting up wildcard subdomains..."
                open File.expand_path("~/vagrant/Vagrantfile"), "a+" do |file|
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
                ::ThemeJuice::warning "Setting up new development site at `#{@opts[:dev_location]}`."
                system [
                    "cd ~/vagrant/www",
                    "mkdir dev-#{@opts[:site_name]}"
                ].join " && "
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
                    ::ThemeJuice::success "Successfully added `vvv-hosts` file."
                else
                    ::ThemeJuice::error "Could not create `vvv-hosts` file."
                end
            end

            ###
            # Add database block to init-custom.sql, create if not exists
            #
            # @return {Void}
            ###
            def setup_database
                File.open File.expand_path("~/vagrant/database/init-custom.sql"), "a+" do |file|
                    file.puts "### Begin `#{@opts[:site_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "CREATE DATABASE IF NOT EXISTS `#{@opts[:db_name]}`;"
                    file.puts "GRANT ALL PRIVILEGES ON `#{@opts[:db_name]}`.* TO '#{@opts[:db_user]}'@'localhost' IDENTIFIED BY '#{@opts[:db_pass]}';"
                    file.puts "### End `#{@opts[:site_name]}`"
                    file.puts "\n"
                end

                if database_is_setup?
                    ::ThemeJuice::success "Successfully added database to `init-custom.sql`."
                else
                    ::ThemeJuice::error "Could not add database info for `#{@opts[:site_name]}` to `init-custom.sql`."
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
                    ::ThemeJuice::success "Successfully added `vvv-nginx.conf` file."
                else
                    ::ThemeJuice::error "Could not create `vvv-nginx.conf` file."
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
                    ::ThemeJuice::success "Successfully added `.env.development` file."
                else
                    ::ThemeJuice::error "Could not create `.env.development` file."
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
                ::ThemeJuice::warning "Setting up WordPress..."

                if @opts[:bare_setup]
                    # Create theme dir
                    system "mkdir -p #{@opts[:site_location]}"
                else
                    # Clone starter, install WP
                    system [
                        "mkdir -p #{@opts[:site_location]} && cd $_",
                        "git clone --depth 1 https://github.com/#{@opts[:starter_theme]}.git .",
                        "composer install",
                    ].join " && "
                end
            end

            ###
            # Add synced folder block to Vagrantfile
            #
            # @return {Void}
            ###
            def setup_synced_folder
                ::ThemeJuice::warning "Syncing host theme directory `#{@opts[:site_location]}` with VM theme directory `/srv/www/dev-#{@opts[:site_name]}`..."

                open File.expand_path("~/vagrant/Vagrantfile"), "a+" do |file|
                    file.puts "### Begin `#{@opts[:site_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "Vagrant.configure('2') do |config|"
                    file.puts "\tconfig.vm.synced_folder '#{@opts[:site_location]}', '/srv/www/dev-#{@opts[:site_name]}', mount_options: ['dmode=777,fmode=777']"
                    file.puts "\tconfig.landrush.host '#{@opts[:dev_url]}', '192.168.50.4'"
                    file.puts "end"
                    file.puts "### End `#{@opts[:site_name]}`"
                    file.puts "\n"
                end
            end

            ###
            # Initialize Git repo, add remote, initial commit
            #
            # @return {Void}
            ###
            def setup_repo
                ::ThemeJuice::warning "Setting up Git repository at `#{@opts[:repository]}`..."

                if repo_is_setup?
                    system [
                        "cd #{@opts[:site_location]}",
                        "rm -rf .git",
                    ].join " && "
                end

                system [
                    "cd #{@opts[:site_location]}",
                    "git init",
                    "git remote add origin #{@opts[:repository]}",
                    "git add -A",
                    "git commit -m 'initial commit'",
                ].join " && "
            end

            ###
            # Remove all theme files from Vagrant directory
            #
            # @return {Void}
            ###
            def remove_dev_site
                ::ThemeJuice::warning "Removing VVV installation..."

                if system "rm -rf #{@opts[:dev_location]}"
                    ::ThemeJuice::success "VVV installation for `#{@opts[:site_name]}` successfully removed."
                else
                    ::ThemeJuice::error "Theme `#{@opts[:site_name]}` could not be removed. Make sure you have write capabilities."
                end
            end

            ###
            # Remove database block from init-custom.sql
            #
            # @return {Void}
            ###
            def remove_database
                ::ThemeJuice::warning "Removing database for `#{@opts[:site_name]}`..."

                if remove_traces_from_file "~/vagrant/database/init-custom.sql"
                    ::ThemeJuice::success "Database for `#{@opts[:site_name]}` successfully removed."
                end
            end

            ###
            # Remove synced folder block from Vagrantfile
            #
            # @return {Void}
            ###
            def remove_synced_folder
                ::ThemeJuice::warning "Removing synced folders for `#{@opts[:site_name]}`..."

                if remove_traces_from_file "~/vagrant/Vagrantfile"
                    ::ThemeJuice::success "Synced folders for `#{@opts[:site_name]}` successfully removed."
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
                        output_file.write "#{file.read}".gsub(/(### Begin `#{@opts[:site_name]}`)(.*?)(### End `#{@opts[:site_name]}`)\n+/m, "")
                    end
                    # Move temp file to actual file location
                    FileUtils.mv output_file, File.expand_path(input_file)
                rescue LoadError => err
                    ::ThemeJuice::error err
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
