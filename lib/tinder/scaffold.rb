require 'securerandom'

module Tinder
    module Scaffold
        class << self

            ###
            # Set up local development environment for theme
            #
            # @param {Hash} opts
            ###
            def create(opts)
                @opts = opts

                ::Tinder::warning "Running setup for `#{@opts[:theme_name]}`..."

                unless wordpress_is_setup?
                    setup_wordpress
                end

                unless theme_is_setup?
                    setup_theme
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

                ###
                # @TODO - This is a hacky workaround for WP uploads dir
                ###
                force_permissions

                if setup_was_successful?
                    ::Tinder::success "Setup successful!"
                    ::Tinder::warning "Restarting VVV..."

                    if restart_vagrant
                        ::Tinder::success "[!] Theme name: #{@opts[:theme_name]}"
                        ::Tinder::success "[!] Theme location: #{@opts[:theme_location]}"
                        ::Tinder::success "[!] Development environment: #{@opts[:dev_location]}"
                        ::Tinder::success "[!] Development url: http://#{@opts[:dev_url]}"
                        ::Tinder::success "[!] Database name: #{@opts[:db_name]}"
                        ::Tinder::success "[!] Database username: #{@opts[:db_user]}"
                        ::Tinder::success "[!] Database password: #{@opts[:db_pass]}"
                        # ::Tinder::success "Database host: #{@opts[:db_host]}"
                    end
                else
                    ::Tinder::error "Setup failed. Running cleanup..."
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
                # @TODO - This is a really hacky way to remove the theme
                ###
                @opts = {
                    :theme_name => theme,
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}")
                }

                ::Tinder::warning "Removing theme `#{@opts[:theme_name]}`..."

                if dev_site_is_setup?
                    remove_dev_site
                end

                if database_is_setup?
                    remove_database
                end

                if synced_folder_is_setup?
                    remove_synced_folder
                end

                if removal_was_successful?
                    ::Tinder::success "Theme `#{@opts[:theme_name]}` successfully removed!"

                    unless restart.nil?
                        ::Tinder::warning "Restarting VVV..."
                        restart_vagrant
                    end
                else
                    ::Tinder::error "Theme `#{@opts[:theme_name]}` could not be fully be removed."
                end
            end

            private

            ###
            # Restart Vagrant
            #
            # Normally a simple `vagrant reload` would work, but landrush requires a
            #   `vagrant up` to be fired for it to set up the DNS.
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
                File.exists? File.expand_path("#{@opts[:theme_location]}/wp-content}")
            end

            ###
            # @return {Bool}
            ###
            def theme_is_setup?
                File.exists? File.expand_path("#{@opts[:theme_location]}/wp-content/themes/#{@opts[:theme_name]}")
            end

            ###
            # @return {Bool}
            ###
            def synced_folder_is_setup?
                File.readlines(File.expand_path "~/vagrant/Vagrantfile").grep(/(### Begin `#{@opts[:theme_name]}`)/m).any?
            end

            ###
            # Force permissions
            ###
            def force_permissions
                system [
                    "chmod -R 777 #{@opts[:theme_location]}",
                    "chmod -R 777 #{@opts[:dev_location]}",
                ].join " && "
            end

            ###
            # Install plugins and clone VVV
            ###
            def setup_vvv
                ::Tinder::warning "Installing VVV into `#{File.expand_path "~/vagrant"}`."
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
                ::Tinder::warning "Setting up wildcard subdomains..."
                open File.expand_path("~/vagrant/Vagrantfile"), "a" do |file|
                    file.puts "###"
                    file.puts "# Enable wildcard subdomains"
                    file.puts "#"
                    file.puts "# This block is automatically generated by Tinder. Do not edit."
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
                ::Tinder::warning "Setting up new development site at `#{@opts[:dev_location]}`."
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
                    ::Tinder::success "Successfully added `vvv-hosts` file."
                else
                    ::Tinder::error "Could not create `vvv-hosts` file."
                end
            end

            ###
            # Add database block to init-custom.sql
            ###
            def setup_database
                File.open File.expand_path("~/vagrant/database/init-custom.sql"), "a" do |file|
                    file.puts "### Begin `#{@opts[:theme_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by Tinder. Do not edit."
                    file.puts "###"
                    file.puts "CREATE DATABASE IF NOT EXISTS `#{@opts[:db_name]}`;"
                    file.puts "GRANT ALL PRIVILEGES ON `#{@opts[:db_name]}`.* TO '#{@opts[:db_user]}'@'localhost' IDENTIFIED BY '#{@opts[:db_pass]}';"
                    file.puts "### End `#{@opts[:theme_name]}`"
                    file.puts "\n"
                end

                if database_is_setup?
                    ::Tinder::success "Successfully added database to `init-custom.sql`."
                else
                    ::Tinder::error "Could not add database info for `#{@opts[:theme_name]}` to `init-custom.sql`."
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
                    ::Tinder::success "Successfully added `vvv-nginx.conf` file."
                else
                    ::Tinder::error "Could not create `vvv-nginx.conf` file."
                end
            end

            ###
            # Setup WordPress
            #
            # Clones official WordPress repo into @opts[:theme_location]
            ###
            def setup_wordpress
                ::Tinder::warning "Setting up WordPress..."

                # Clone WP, create config file from sample
                system [
                    "mkdir -p #{@opts[:theme_location]} && cd $_",
                    "git clone --depth 1 https://github.com/WordPress/WordPress.git .",
                    "cp wp-config-sample.php wp-config.php",
                ].join " && "

                # Setup config
                setup_wordpress_config "#{@opts[:theme_location]}/wp-config.php"

                # Create uploads dir
                system "mkdir -p #{@opts[:theme_location]}/wp-content/uploads"
            end

            ###
            # Setup WordPress config file
            ###
            def setup_wordpress_config(input_file)
                begin
                    # Create new tempfile
                    output_file = Tempfile.new File.basename(input_file)
                    # Copy over contents of actual file to tempfile
                    open File.expand_path(input_file), "rb" do |file|
                        # Get the contents
                        contents = "#{file.read}"
                        # Replace config info
                        contents = contents.gsub(/(database_name_here)/, @opts[:db_name])
                        contents = contents.gsub(/(username_here)/, @opts[:db_user])
                        contents = contents.gsub(/(password_here)/, @opts[:db_pass])
                        contents = contents.gsub(/(localhost)/, @opts[:dev_url])
                        contents = contents.gsub(/(put\syour\sunique\sphrase\shere)/, SecureRandom.hex(20))
                        # Write to temp file
                        output_file.write contents
                    end
                    # Move temp file to actual file location
                    FileUtils.mv output_file, File.expand_path(input_file)
                rescue LoadError => err
                    ::Tinder::error err
                    exit -1
                ensure
                    # Make sure that the tempfile closes and is cleaned up, regardless of errors
                    output_file.close
                    output_file.unlink
                end
            end

            ###
            # Setup theme directory
            ###
            def setup_theme
                ::Tinder::warning "Setting up theme..."
                system [
                    "cd #{@opts[:theme_location]}/wp-content/themes",
                    "git clone --depth 1 https://github.com/ezekg/tinder.git #{@opts[:theme_name]}"
                ].join " && "

                # Setup synced folders
                unless synced_folder_is_setup?
                    ::Tinder::warning "Syncing host theme directory `#{@opts[:theme_location]}` with VM theme directory `/srv/www/dev-#{@opts[:theme_name]}`..."
                    setup_synced_folder
                end
            end

            ###
            # Add synced folder block to Vagrantfile
            ###
            def setup_synced_folder
                open File.expand_path("~/vagrant/Vagrantfile"), "a" do |file|
                    file.puts "### Begin `#{@opts[:theme_name]}`"
                    file.puts "#"
                    file.puts "# This block is automatically generated by Tinder. Do not edit."
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
            # Remove all theme files from Vagrant directory
            ###
            def remove_dev_site
                ::Tinder::warning "Removing VVV installation..."

                if system "rm -rf #{@opts[:dev_location]}"
                    ::Tinder::success "VVV installation for `#{@opts[:theme_name]}` successfully removed."
                else
                    ::Tinder::error "Theme `#{@opts[:theme_name]}` could not be removed. Make sure you have write capabilities."
                end
            end

            ###
            # Remove database block from init-custom.sql
            ###
            def remove_database
                ::Tinder::warning "Removing database for `#{@opts[:theme_name]}`..."

                if remove_traces_from_file "~/vagrant/database/init-custom.sql"
                    ::Tinder::success "Database for `#{@opts[:theme_name]}` successfully removed."
                end
            end

            ###
            # Remove synced folder block from Vagrantfile
            ###
            def remove_synced_folder
                ::Tinder::warning "Removing synced folders for `#{@opts[:theme_name]}`..."

                if remove_traces_from_file "~/vagrant/Vagrantfile"
                    ::Tinder::success "Synced folders for `#{@opts[:theme_name]}` successfully removed."
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
                    ::Tinder::error err
                    exit -1
                ensure
                    # Make sure that the tempfile closes and is cleaned up, regardless of errors
                    output_file.close
                    output_file.unlink
                end
            end
        end
    end
end
