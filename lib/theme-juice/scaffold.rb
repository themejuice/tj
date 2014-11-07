module ThemeJuice
    module Scaffold
        class << self

            ###
            # Set up local development environment for theme
            #
            # @param {Hash} opts
            ###
            def create(opts)
                @opts = opts

                ::ThemeJuice::warning "Running setup for `#{@opts[:theme_name]}`..."

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

                if @opts[:repository] != "none"
                    setup_repo
                end

                ###
                # @TODO - This is a hacky workaround for WP uploads dir
                ###
                # force_permissions

                if setup_was_successful?
                    ::ThemeJuice::success "Setup successful!"
                    ::ThemeJuice::warning "Restarting VVV..."

                    if restart_vagrant
                        ::ThemeJuice::success "Theme name: #{@opts[:theme_name]}"
                        ::ThemeJuice::success "Theme location: #{@opts[:theme_location]}"
                        ::ThemeJuice::success "Development environment: #{@opts[:dev_location]}"
                        ::ThemeJuice::success "Development url: http://#{@opts[:dev_url]}"
                        ::ThemeJuice::success "Repository: #{@opts[:repository]}"
                        ::ThemeJuice::success "Database host: #{@opts[:db_host]}"
                        ::ThemeJuice::success "Database name: #{@opts[:db_name]}"
                        ::ThemeJuice::success "Database username: #{@opts[:db_user]}"
                        ::ThemeJuice::success "Database password: #{@opts[:db_pass]}"
                    end
                else
                    ::ThemeJuice::error "Setup failed. Running cleanup..."
                    delete @opts[:theme_name], false
                end
            end

            ###
            # Remove all traces of theme from Vagrant
            #
            # @param {String} theme
            # @param {Bool}   restart
            ###
            def delete(theme, restart)

                ###
                # @TODO - This is a really hacky way to remove the theme.
                #   Eventually I'd like to handle state.
                ###
                @opts = {
                    :theme_name => theme,
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}")
                }

                if dev_site_is_setup?
                    ::ThemeJuice::warning "Removing theme `#{@opts[:theme_name]}`..."
                    remove_dev_site
                else
                    ::ThemeJuice::error "Theme `#{@opts[:theme_name]}` does not exist."
                    exit 1
                end

                if database_is_setup?
                    remove_database
                end

                if synced_folder_is_setup?
                    remove_synced_folder
                end

                if removal_was_successful?
                    ::ThemeJuice::success "Theme `#{@opts[:theme_name]}` successfully removed!"

                    unless restart.nil?
                        ::ThemeJuice::warning "Restarting VVV..."
                        restart_vagrant
                    end
                else
                    ::ThemeJuice::error "Theme `#{@opts[:theme_name]}` could not be fully be removed."
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
            # Normally a simple `vagrant reload` would work, but Landrush requires a
            #   `vagrant up` to be fired for it to set up the DNS correctly.
            ###
            def restart_vagrant
                system [
                    "cd ~/vagrant",
                    "vagrant halt",
                    "vagrant up --provision"
                ].join " && "
            end

            ###
            # Get the theme directory name
            #
            # @return {String}
            ###
            def get_theme_name
                Pathname.new(__FILE__).ascend { |f| return f.parent.basename if f.basename.to_s == "lib" }
            end

            ###
            # Get the theme directory path
            #
            # @return {String}
            ###
            def get_theme_location
                Pathname.new(__FILE__).ascend { |f| return f.parent.realpath if f.basename.to_s == "lib" }
            end

            ###
            # @return {Bool}
            ###
            def setup_was_successful?
                vvv_is_setup? and dev_site_is_setup? and hosts_is_setup? and database_is_setup? and nginx_is_setup? ? true : false
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
                File.exists? "#{@opts[:theme_location]}/vvv-hosts"
            end

            ###
            # @return {Bool}
            ###
            def database_is_setup?
                File.readlines(File.expand_path "~/vagrant/database/init-custom.sql").grep(/(### Begin `#{@opts[:theme_name]}`)/m).any?
            end

            ###
            # @return {Bool}
            ###
            def nginx_is_setup?
                File.exists? "#{@opts[:theme_location]}/vvv-nginx.conf"
            end

            ###
            # @return {Bool}
            ###
            def wordpress_is_setup?
                File.exists? File.expand_path("#{@opts[:theme_location]}/app")
            end

            ###
            # @return {Bool}
            ###
            def synced_folder_is_setup?
                File.readlines(File.expand_path "~/vagrant/Vagrantfile").grep(/(### Begin `#{@opts[:theme_name]}`)/m).any?
            end

            ###
            # @return {Bool}
            ###
            def repo_is_setup?
                File.exists? File.expand_path("#{@opts[:theme_location]}/.git")
            end

            ###
            # @return {Bool}
            ###
            def env_is_setup?
                File.exists? File.expand_path("#{@opts[:theme_location]}/.env")
            end

            ###
            # Force permissions for WP install to be executable
            ###
            def force_permissions
                ::ThemeJuice::warning "Modifying permissions for WordPress installation..."
                system [
                    "chmod -R +x #{@opts[:theme_location]}",
                    "chmod -R +x #{@opts[:dev_location]}",
                ].join " && "
            end

            ###
            # Install plugins and clone VVV
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
            # Clone WP and remove wp-config
            ###
            def setup_dev_site
                ::ThemeJuice::warning "Setting up new development site at `#{@opts[:dev_location]}`."
                system [
                    "cd ~/vagrant/www",
                    "mkdir dev-#{@opts[:theme_name]}"
                ].join " && "
            end

            ###
            # Create vvv-hosts file
            ###
            def setup_hosts
                File.open "#{@opts[:theme_location]}/vvv-hosts", "w" do |file|
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
            ###
            def setup_database
                File.open File.expand_path("~/vagrant/database/init-custom.sql"), "a+" do |file|
                    file.puts "### Begin `#{@opts[:theme_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "CREATE DATABASE IF NOT EXISTS `#{@opts[:db_name]}`;"
                    file.puts "GRANT ALL PRIVILEGES ON `#{@opts[:db_name]}`.* TO '#{@opts[:db_user]}'@'localhost' IDENTIFIED BY '#{@opts[:db_pass]}';"
                    file.puts "### End `#{@opts[:theme_name]}`"
                    file.puts "\n"
                end

                if database_is_setup?
                    ::ThemeJuice::success "Successfully added database to `init-custom.sql`."
                else
                    ::ThemeJuice::error "Could not add database info for `#{@opts[:theme_name]}` to `init-custom.sql`."
                end
            end

            ###
            # Create vvv-nginx.conf file for local development site
            ###
            def setup_nginx
                File.open "#{@opts[:theme_location]}/vvv-nginx.conf", "w" do |file|
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
            ###
            def setup_env
                File.open "#{@opts[:theme_location]}/.env.development", "w" do |file|
                    file.puts "DB_NAME=#{@opts[:db_name]}"
                    file.puts "DB_USER=#{@opts[:db_user]}"
                    file.puts "DB_PASSWORD=#{@opts[:db_pass]}"
                    file.puts "DB_HOST=#{@opts[:db_host]}"
                    file.puts "WP_HOME=http://#{@opts[:dev_url]}"
                    file.puts "WP_SITEURL=http://#{@opts[:dev_url]}/wp"
                end

                if env_is_setup?
                    ::ThemeJuice::success "Successfully added `.env` file."
                else
                    ::ThemeJuice::error "Could not create `.env` file."
                end
            end

            ###
            # Setup WordPress
            #
            # Clones official WordPress repo into @opts[:theme_location]
            ###
            def setup_wordpress
                ::ThemeJuice::warning "Setting up WordPress..."

                unless wordpress_is_setup?
                    if @opts[:bare_setup]
                        # Create theme dir
                        system "mkdir -p #{@opts[:theme_location]}"
                    else
                        # Clone starter, install WP
                        system [
                            "mkdir -p #{@opts[:theme_location]} && cd $_",
                            "git clone --depth 1 https://github.com/ezekg/theme-juice-starter.git .",
                            "composer install",
                        ].join " && "
                    end
                end

                # Setup environment
                unless env_is_setup?
                    setup_env
                end

                # Setup synced folders
                unless synced_folder_is_setup?
                    ::ThemeJuice::warning "Syncing host theme directory `#{@opts[:theme_location]}` with VM theme directory `/srv/www/dev-#{@opts[:theme_name]}`..."
                    setup_synced_folder
                end
            end

            ###
            # Add synced folder block to Vagrantfile
            ###
            def setup_synced_folder
                open File.expand_path("~/vagrant/Vagrantfile"), "a+" do |file|
                    file.puts "### Begin `#{@opts[:theme_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by ThemeJuice. Do not edit."
                    file.puts "###"
                    file.puts "Vagrant.configure('2') do |config|"
                    file.puts "\tconfig.vm.synced_folder '#{@opts[:theme_location]}', '/srv/www/dev-#{@opts[:theme_name]}', mount_options: ['dmode=777,fmode=777']"
                    file.puts "\tconfig.landrush.host '#{@opts[:dev_url]}', '192.168.50.4'"
                    file.puts "end"
                    file.puts "### End `#{@opts[:theme_name]}`"
                    file.puts "\n"
                end
            end

            ###
            # Initialize Git repo, add remote, initial commit
            ###
            def setup_repo
                ::ThemeJuice::warning "Setting up Git repository at `#{@opts[:repository]}`..."

                if repo_is_setup?
                    system [
                        "cd #{@opts[:theme_location]}",
                        "rm -rf .git",
                    ].join " && "
                end

                system [
                    "cd #{@opts[:theme_location]}",
                    "git init",
                    "git remote add origin #{@opts[:repository]}",
                    "git add -A",
                    "git commit -m 'initial commit'",
                ].join " && "
            end

            ###
            # Remove all theme files from Vagrant directory
            ###
            def remove_dev_site
                ::ThemeJuice::warning "Removing VVV installation..."

                if system "rm -rf #{@opts[:dev_location]}"
                    ::ThemeJuice::success "VVV installation for `#{@opts[:theme_name]}` successfully removed."
                else
                    ::ThemeJuice::error "Theme `#{@opts[:theme_name]}` could not be removed. Make sure you have write capabilities."
                end
            end

            ###
            # Remove database block from init-custom.sql
            ###
            def remove_database
                ::ThemeJuice::warning "Removing database for `#{@opts[:theme_name]}`..."

                if remove_traces_from_file "~/vagrant/database/init-custom.sql"
                    ::ThemeJuice::success "Database for `#{@opts[:theme_name]}` successfully removed."
                end
            end

            ###
            # Remove synced folder block from Vagrantfile
            ###
            def remove_synced_folder
                ::ThemeJuice::warning "Removing synced folders for `#{@opts[:theme_name]}`..."

                if remove_traces_from_file "~/vagrant/Vagrantfile"
                    ::ThemeJuice::success "Synced folders for `#{@opts[:theme_name]}` successfully removed."
                end
            end

            ###
            # Remove all traces of auto-generated content from file
            #
            # @param {String} input_file
            ###
            def remove_traces_from_file(input_file)
                begin
                    # Create new tempfile
                    output_file = Tempfile.new File.basename(input_file)
                    # Copy over contents of actual file to tempfile
                    open File.expand_path(input_file), "rb" do |file|
                        # Remove traces of theme from contents
                        output_file.write "#{file.read}".gsub(/(### Begin `#{@opts[:theme_name]}`)(.*?)(### End `#{@opts[:theme_name]}`)\n+/m, "")
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
