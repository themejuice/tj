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
            #
            # @return {Void}
            ###
            def install_dependencies

                ###
                # Vagrant
                ###
                unless ::ThemeJuice::installed? "vagrant"
                    ::ThemeJuice::error "Vagrant doesn't seem to be installed. Download Vagrant and VirtualBox before running this task. See README for more information."
                    exit 1
                end

                ###
                # Composer
                ###
                unless ::ThemeJuice::installed? "composer"
                    ::ThemeJuice::error "Composer doesn't seem to be installed, or is not globally executable."
                    if yes? "Do you want to globally install it? (y/N)", :blue
                        ::ThemeJuice::warning "Installing Composer..."
                        ::ThemeJuice::warning "This task uses `sudo` to move the installed `composer.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -sS https://getcomposer.org/installer | php",
                            "sudo mv composer.phar /usr/local/bin/composer"
                        ].join " && "
                    else
                        ::ThemeJuice::warning "To proceed, install Composer manually and make sure it is globally executable."
                        exit 1
                    end
                end

                ###
                # WP-CLI
                ###
                unless ::ThemeJuice::installed? "wp"
                    ::ThemeJuice::error "WP-CLI doesn't seem to be installed, or is not globally executable."
                    if yes? "Do you want to globally install it? (y/N)", :blue
                        ::ThemeJuice::warning "Installing WP-CLI..."
                        ::ThemeJuice::warning "This task uses `sudo` to move the installed `wp-cli.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
                            "chmod +x wp-cli.phar",
                            "sudo mv wp-cli.phar /usr/local/bin/wp"
                        ].join " && "
                    else
                        ::ThemeJuice::warning "To proceed, install WP-CLI manually and make sure it is globally executable."
                        exit 1
                    end
                end
            end
        end

        ###
        # Install and setup VVV environment
        #
        # @return {Void}
        ###
        desc "init", "Setup Vagrant development environment"
        def init
            self.install_dependencies

            # Set up ASCII font
            f = ::Artii::Base.new font: "rowancap"

            # Output ASCII welcome message
            ::ThemeJuice::welcome ""
            ::ThemeJuice::welcome f.asciify("theme"), "green"
            ::ThemeJuice::welcome f.asciify("juice"), "green"

            # Setup the development environment!
            ::ThemeJuice::Scaffold::init
        end

        ###
        # Install and setup VVV environment with new site
        #
        # @param {String} site (nil)
        #   Name of the site to create
        # @param {Bool}   bare (false)
        #   Create a bare VVV site without starter
        #
        # @return {Void}
        ###
        desc "create [SITE]", "Setup SITE and Vagrant development environment"
        method_option :bare, type: :boolean, desc: "Create a Vagrant site without starter theme"
        def create(site = nil, bare_setup = false)
            self.install_dependencies

            ###
            # Welcome message
            ###
            # Set up ASCII font
            f = ::Artii::Base.new font: "rowancap"

            # Output ASCII welcome message
            ::ThemeJuice::newline
            ::ThemeJuice::welcome f.asciify("theme"), "green"
            ::ThemeJuice::welcome f.asciify("juice"), "green"
            ::ThemeJuice::welcome "Welcome to Theme Juice! Don't worry about copying any of your settings right now. All "\
            "your information will be provided to you after the setup is complete. If this is your very first "\
            "setup, it will take around 20 minutes to setup the VM. So, grab some coffee, maybe a good book "\
            "and sit back and watch the magic unfold.", "green"
            ::ThemeJuice::newline

            ###
            # Theme setup
            ###
            if site.nil?
                ::ThemeJuice::warning "Just a few questions before we begin..."
            else
                ::ThemeJuice::warning "Just a few more questions before we begin..."
            end

            # Color of prompts
            prompt_color = :blue

            # Ask for the Site name if not passed directly
            site ||= ask "[?] What's the site name? Only ascii characters are allowed:", prompt_color

            if site.match /[^0-9A-Za-z.\-]/
                ::ThemeJuice::error "Site name contains invalid non-ascii characters. This name is used for creating directories, so that's not gonna work. Aborting mission."
                exit 1
            end

            # Bare install
            bare_setup ||= options[:bare]

            # Make sure Site name was given, else throw err
            unless site.empty?
                clean_site_name = site.gsub(/[^\w]/, "_")[0..10]

                ###
                # Location of site installation
                ###
                site_location = ask "[?] Where do you want to setup the site?", prompt_color,
                    default: "#{Dir.pwd}/",
                    path: true

                ###
                # Starter theme to clone
                ###
                unless bare_setup
                    starter_theme = ask "[?] Which starter theme would you like to use?", prompt_color,
                        default: "ezekg/theme-juice-starter",
                        limited_to: [
                            "ezekg/theme-juice-starter",
                            "other",
                            "none"
                        ]
                    case starter_theme
                    when "other"
                        starter_theme = ask "[?] What is the user/repository of the starter theme you would like to clone?", prompt_color
                    when "none"
                        ::ThemeJuice::warning "Next time you want to create a site without a starter theme, you can just run the `setup` command instead."
                        bare_setup = true
                    end
                end

                ###
                # Development url
                ###
                dev_url = ask "[?] What do you want the development url to be? (this should end in `.dev`)", prompt_color,
                    default: "#{site}.dev"

                ###
                # Initialize a git repository on setup
                ###
                if yes? "[?] Would you like to initialize a new Git repository? (y/N)", prompt_color
                    repository = ask "[?] Repository URL:", prompt_color
                else
                    repository = false
                end

                ###
                # Database host
                ###
                db_host = ask "[?] Database host:", prompt_color,
                    default: "vvv"

                ###
                # Database name
                ###
                db_name = ask "[?] Database name:", prompt_color,
                    default: "#{clean_site_name}_db"

                ###
                # Database username
                ###
                db_user = ask "[?] Database username:", prompt_color,
                    default: "#{clean_site_name}_user"

                ###
                # Database password
                ###
                db_pass = ask "[?] Database password:", prompt_color,
                    default: SecureRandom.base64

                ###
                # Save options
                ###
                opts = {
                    site_name: site,
                    site_location: File.expand_path(site_location),
                    starter_theme: starter_theme,
                    bare_setup: bare_setup,
                    dev_location: File.expand_path("~/vagrant/www/tj-#{site}"),
                    dev_url: dev_url,
                    repository: repository,
                    db_host: db_host,
                    db_name: db_name,
                    db_user: db_user,
                    db_pass: db_pass,
                }

                # Create the theme!
                ::ThemeJuice::Scaffold::create opts
            else
                ::ThemeJuice::error "Site name is required. Aborting mission."
                exit 1
            end
        end

        ###
        # Setup an existing WordPress install in VVV
        #
        # @param {String} site (nil)
        #   Name of the theme to create
        #
        # @return {Void}
        ###
        desc "setup [SITE]", "Create a Vagrant site without starter theme (alias for `create --bare`)"
        def setup(site = nil)
            self.create site, true
        end

        ###
        # Remove all traces of site from Vagrant
        #
        # @param {String} site
        #   Theme to delete. This will not delete your local files, only the VVV env.
        #
        # @return {Void}
        ###
        desc "delete SITE", "Remove SITE from Vagrant development environment (does not remove local site)"
        method_option :restart, type: :boolean
        def delete(site)
            if yes? "[?] Are you sure you want to delete site `#{site}`? (y/N)", :blue
                ::ThemeJuice::Scaffold::delete site, options[:restart]
            end
        end

        ###
        # List all development sites
        #
        # @return {Void}
        ###
        desc "list", "List all sites within Vagrant development environment"
        def list
            ::ThemeJuice::Scaffold::list
        end

        ###
        # Guard
        #
        # @param {*} command
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "watch [COMMAND]", "Watch and compile assets with Guard (alias for `bundle exec guard [COMMAND]`)"
        def watch(*command)
            system "bundle exec guard #{command.join(" ")}"
        end

        ###
        # Vagrant
        #
        # @param {*} command
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vm [COMMAND]", "Manage virtual development environment with Vagrant (alias for `vagrant [COMMAND]`)"
        def vm(*command)
            system "cd ~/vagrant && vagrant #{command.join(" ")}"
        end

        ###
        # Composer
        #
        # @param {*} command
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vendor [COMMAND]", "Manage vendor dependencies with Composer (alias for `composer [COMMAND]`)"
        def vendor(*command)
            system "composer #{command.join(" ")}"
        end

        ###
        # Capistrano
        #
        # @param {*} command
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "server [COMMAND]", "Manage deployment and migration with Capistrano (alias for `bundle exec cap [COMMAND]`)"
        def server(*command)
            system "bundle exec cap #{command.join(" ")}"
        end
    end
end
