module ThemeJuice

    ###
    # CLI interface to run subcommands from
    ###
    class CLI < ::Thor
        include ::Thor::Actions

        ###
        # Non Thor commands
        ###
        no_commands do

            ###
            # Make sure all dependencies are installed and globally executable.
            #   Will prompt for install if available.
            ###
            def install_dependencies
                ::ThemeJuice::warning "Making sure all dependencies are installed..."

                ###
                # Vagrant
                ###
                if ::ThemeJuice::installed? "vagrant"
                    ::ThemeJuice::success "Vagrant is installed!"
                else
                    ::ThemeJuice::error "Vagrant doesn't seem to be installed. Download Vagrant and VirtualBox before running this task. See README for more information."
                    exit 1
                end

                ###
                # Composer
                ###
                if ::ThemeJuice::installed? "composer"
                    ::ThemeJuice::success "Composer is installed!"
                else
                    ::ThemeJuice::error "Composer doesn't seem to be installed, or is not globally executable."
                    answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                    if answer == "yes"
                        ::ThemeJuice::warning "Installing Composer..."
                        ::ThemeJuice::warning "This task uses `sudo` to move the installed `composer.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -sS https://getcomposer.org/installer | php",
                            "sudo mv composer.phar /usr/local/bin/composer"
                        ].join " && "
                    else
                        ::ThemeJuice::warning "To use proceed, install Composer manually and make sure it is globally executable."
                        exit 1
                    end
                end

                ###
                # WP-CLI
                ###
                if ::ThemeJuice::installed? "wp"
                    ::ThemeJuice::success "WP-CLI is installed!"
                else
                    ::ThemeJuice::error "WP-CLI doesn't seem to be installed, or is not globally executable."
                    answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                    if answer == "yes"
                        ::ThemeJuice::warning "Installing WP-CLI..."
                        ::ThemeJuice::warning "This task uses `sudo` to move the installed `wp-cli.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
                            "chmod +x wp-cli.phar",
                            "sudo mv wp-cli.phar /usr/local/bin/wp"
                        ].join " && "
                    else
                        ::ThemeJuice::warning "To use proceed, install WP-CLI manually and make sure it is globally executable."
                        exit 1
                    end
                end
            end
        end

        ###
        # Install and setup VVV environment
        #
        # It will automagically set up your entire development environment, including
        #   a local development site at `http://site.dev` with WordPress installed
        #   and with a fresh WP database. It will also sync up your current theme
        #   folder with the theme folder on the Vagrant VM. This task will also
        #   install and configure Vagrant/VVV into your `~/` directory.
        #
        # @param {String} theme
        #   Name of the theme to create
        # @param {Bool}   bare
        #   Create a bare VVV site without starter
        ###
        desc "create [THEME]", "Setup THEME and Vagrant development environment"
        method_option :bare, :type => :boolean, :desc => "Create a bare Vagrant site without starter"
        def create(theme = nil, bare = false)
            self.install_dependencies

            # Set up ASCII font
            f = ::Artii::Base.new :font => "rowancap"

            # Output ASCII welcome message
            ::ThemeJuice::welcome ""
            ::ThemeJuice::welcome f.asciify("theme"), "green"
            ::ThemeJuice::welcome f.asciify("juice"), "green"

            ###
            # Theme setup
            ###
            if theme.nil?
                ::ThemeJuice::warning "Just a few questions before we begin..."
            else
                ::ThemeJuice::warning "Just a few more questions before we begin..."
            end

            # Ask for the theme name if not passed directly
            theme ||= ask "[?] Theme name (required):"

            # Bare install
            bare ||= options[:bare]

            # Make sure theme name was given, else throw err
            unless theme.empty?

                theme_location = ask "[?] Theme location:",
                    :default => "#{Dir.pwd}/"
                dev_url = ask "[?] Development url:",
                    :default => "#{theme}.dev"
                repository = ask "[?] Git repository:",
                    :default => "none"
                db_host = ask "[?] Database host:",
                    :default => "vvv"
                db_name = ask "[?] Database name:",
                    :default => "wordpress"
                db_user = ask "[?] Database username:",
                    :default => "wordpress"
                db_pass = ask "[?] Database password:",
                    :default => SecureRandom.base64

                # Ask for other options
                opts = {
                    :theme_name => theme,
                    :theme_location => File.expand_path(theme_location),
                    :bare_setup => bare,
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}"),
                    :dev_url => dev_url,
                    :repository => repository,
                    :db_host => db_host,
                    :db_name => db_name,
                    :db_user => db_user,
                    :db_pass => db_pass,
                }

                # Create the theme!
                ::ThemeJuice::Scaffold::create opts
            else
                ::ThemeJuice::error "Theme name is required. Aborting mission."
                exit 1
            end
        end

        ###
        # Setup an existing WordPress install in VVV
        #
        # @param {String} theme
        #   Name of the theme to create
        ###
        desc "setup [THEME]", "Alias for `create --bare`. Setup an existing WordPress install in VVV"
        def setup(theme = nil)
            self.create theme, true
        end

        ###
        # Remove all traces of site from Vagrant
        #
        # @param {String} theme
        #   Theme to delete. This will not delete your local files, only the VVV env.
        ###
        desc "delete THEME", "Remove THEME from Vagrant development environment. Does not remove local theme."
        method_option :restart, :type => :boolean
        def delete(theme)
            ::ThemeJuice::warning "This method will only remove the site from within the VM. It does not remove your local theme."

            answer = ask "[?] Are you sure you want to delete theme `#{theme}`?",
                :limited_to => ["y", "n"]

            if answer == "y"
                ::ThemeJuice::Scaffold::delete theme, options[:restart]
            end
        end

        ###
        # List all development sites
        ###
        desc "list", "List all themes within Vagrant development environment"
        def list
            ::ThemeJuice::Scaffold::list
        end

        ###
        # Watch and compile assets
        ###
        desc "watch", "Watch and compile assets with Guard"
        method_option :plugin, :default => "all", :aliases => "-p", :desc => "Watch and compile specific plugin"
        def watch
            ::ThemeJuice::warning "Starting Guard..."
            ::ThemeJuice::Plugins::Guard::send options[:plugin]
        end

        ###
        # Optimize images
        ###
        desc "optimize", "Optimize images with Guard"
        def optimize
            ::ThemeJuice::warning "Optimizing images..."
            ::ThemeJuice::Plugins::Guard::image_optim
        end

        ###
        # Vagrant
        ###
        desc "vm", "Manage virtual development environment with Vagrant"
        subcommand "vm", ::ThemeJuice::Plugins::Vagrant

        ###
        # Composer
        ###
        desc "vendor", "Manage vendor dependencies with Composer"
        subcommand "vendor", ::ThemeJuice::Plugins::Composer

        ###
        # Mina
        ###
        desc "server", "Deploy site with Mina"
        subcommand "server", ::ThemeJuice::Plugins::Mina
    end
end
