module ThemeJuice
    class CLI < ::Thor

        ###
        # Non Thor commands
        ###
        no_commands do

            ###
            # Welcome message
            #
            # @return {Void}
            ###
            def welcome

              # Get WP logo ASCII art
              logo = File.read(File.expand_path("../ascii/logo.txt", __FILE__))

              # Output welcome message
              say "\n"
              say logo.gsub(/[m]/) { |char| set_color(char, :green) }.gsub(/[\+\/\-\'\:\.\~dyhos]/) { |char| set_color(char, :yellow) }
              say "\n"
              say "Welcome to Theme Juice!".center(60), :green
              say "\n\n"
            end
        end

        ###
        # Install and setup VVV environment
        #
        # @return {Void}
        ###
        desc "init", "Setup the VVV environment"
        def init
            self.welcome

            # Setup the VM
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
        desc "create [SITE]", "Setup SITE and the VVV development environment"
        method_option :bare, type: :boolean, desc: "Create a VVV site without the starter theme"
        def create(site = nil, bare_setup = false)
            self.welcome

            ###
            # Theme setup
            ###
            if site.nil?
                say "Just a few questions before we begin...", :yellow
            else
                say "Your site name shall be #{site}! Just a few more questions before we begin...", :yellow
            end

            # ask for the Site name if not passed directly
            site ||= ask "What's the site name? (only ascii characters are allowed) :", :green

            if site.match /[^0-9A-Za-z.\-]/
                say "Site name contains invalid non-ascii characters. This name is used for creating directories, so that's not gonna work. Aborting mission.", :red
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
                site_location = ask "Where do you want to setup the site? :", :green,
                    default: "#{Dir.pwd}/",
                    path: true

                ###
                # Starter theme to clone
                ###
                unless bare_setup
                    require "highline/import"

                    starter_theme = nil

                    say "Which starter theme would you like to use? :", :green
                    choose do |menu|
                        menu.index_suffix = ") "

                        menu.choice "ezekg/theme-juice-starter" do |c|
                            say "Awesome choice!", :green
                            starter_theme = c
                        end

                        menu.choice "other" do
                            starter_theme = ask "What is the user/repository of the starter theme you would like to clone? :", :green
                        end

                        menu.choice "none" do |c|
                            say "Next time you want to create a site without a starter theme, you can just run the 'setup' command instead.", :yellow
                            starter_theme, bare_setup = c, true
                        end
                    end
                end

                ###
                # Development url
                ###
                dev_url = ask "What do you want the development url to be? (this should end in '.dev') :", :green,
                    default: "#{site}.dev"

                unless dev_url.match /(.dev)$/
                    say "Your development url doesn't end with '.dev'. This is used within Vagrant, so that's not gonna work. Aborting mission.", :red
                    exit 1
                end

                ###
                # Initialize a git repository on setup
                ###
                if yes? "Would you like to initialize a new Git repository? (y/N) :", :green
                    repository = ask "Remote URL :", :green
                else
                    repository = false
                end

                ###
                # Database host
                ###
                db_host = ask "Database host :", :green,
                    default: "vvv"

                ###
                # Database name
                ###
                db_name = ask "Database name :", :green,
                    default: "#{clean_site_name}_db"

                ###
                # Database username
                ###
                db_user = ask "Database username :", :green,
                    default: "#{clean_site_name}_user"

                ###
                # Database password
                ###
                db_pass = ask "Database password :", :green,
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
                say "Site name is required. Aborting mission.", :red
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
        desc "setup [SITE]", "Create a VVV site without starter theme (alias for 'create --bare')"
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
        desc "delete SITE", "Remove SITE from the VVV development environment (does not remove local site)"
        method_option :restart, type: :boolean
        def delete(site)
            if yes? "Are you sure you want to delete '#{site}'? (y/N)", :red
                ::ThemeJuice::Scaffold::delete site, options[:restart]
            end
        end

        ###
        # List all development sites
        #
        # @return {Void}
        ###
        desc "list", "List all sites within the VVV development environment"
        def list
            ::ThemeJuice::Scaffold::list
        end

        ###
        # Guard
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "watch [COMMANDS]", "Watch and compile assets with Guard (alias for 'bundle exec guard [COMMANDS]')"
        def watch(*commands)
            system "bundle exec guard #{commands.join(" ")}"
        end

        ###
        # Vagrant
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vm [COMMANDS]", "Manage virtual development environment with Vagrant (alias for 'vagrant [COMMANDS]')"
        def vm(*commands)
            system "cd ~/vagrant && vagrant #{commands.join(" ")}"
        end

        ###
        # Composer
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vendor [COMMANDS]", "Manage vendor dependencies with Composer (alias for 'composer [COMMANDS]')"
        def vendor(*commands)
            system "composer #{commands.join(" ")}"
        end

        ###
        # Capistrano
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "server [COMMANDS]", "Manage deployment and migration with Capistrano (alias for 'bundle exec cap [COMMANDS]')"
        def server(*commands)
            system "bundle exec cap #{commands.join(" ")}"
        end
    end
end
