module ThemeJuice
    class CLI < ::Thor

        map %w[--version -v]      => :version
        map %w[new, build, make]  => :create
        map %w[setup, init, prep] => :create
        map %w[remove, teardown]  => :delete
        map %w[sites, show]       => :list
        map %w[dev]               => :watch
        map %w[dep, deps]         => :vendor
        map %w[deploy]            => :server
        map %w[vagrant, vvv]      => :vm

        class_option :vvv_path, type: :string, alias: "-fp", default: nil, desc: "Force path to VVV installation"

        ###
        # Non-Thor commands
        ###
        no_commands do

            ###
            # Set VVV path
            #
            # @return {Void}
            ###
            def force_vvv_path?
                unless options[:vvv_path].nil?
                    ::ThemeJuice::Utilities.set_vvv_path options[:vvv_path]
                end
            end

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
        # Print current version
        #
        # @return {String}
        ###
        desc "--version, -v", "Print current version"
        def version
            # ::ThemeJuice::Utilities.check_if_current_version_is_outdated

            say ::ThemeJuice::VERSION, :green
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
        desc "create [SITE]", "Create new SITE and setup the VVV development environment"
        method_option :bare,       type: :boolean, aliases: "-b",                 desc: "Create a VVV site without a starter theme"
        method_option :site,       type: :string,  aliases: "-s", default: false, desc: "Name of the development site"
        method_option :location,   type: :string,  aliases: "-l", default: false, desc: "Location of the local site"
        method_option :theme,      type: :string,  aliases: "-t", default: false, desc: "Starter theme to install"
        method_option :url,        type: :string,  aliases: "-u", default: false, desc: "Development URL of the site"
        method_option :repository, type: :string,  aliases: "-r",                 desc: "Initialize a new Git remote repository"
        method_option :skip_repo,  type: :boolean,                                desc: "Skip repository prompts and use defaults"
        method_option :skip_db,    type: :boolean,                                desc: "Skip database prompts and use defaults"
        def create(site = nil)
            self.force_vvv_path?
            self.welcome

            if options[:site]
                site = options[:site]
            end

            # Check if user passed all required options through flags
            if options.length >= 6
                say "Well... looks like you just have everything all figured out, huh?", :yellow
            elsif site.nil?
                say "Just a few questions before we begin...", :yellow
            else
                say "Your site name shall be '#{site}'! Just a few more questions before we begin...", :yellow
            end

            # Ask for the Site name if not passed directly
            site ||= ask "What's the site name? (only ascii characters are allowed) :", :blue

            # Make sure site name is valid
            if site.match /[^0-9A-Za-z.\-]/
                say "Site name contains invalid non-ascii characters. This name is used for creating directories, so that's not gonna work. Aborting mission.", :red
                exit 1
            end

            # Bare install?
            bare_setup ||= options[:bare]

            # Make sure Site name was given, else throw err
            unless site.empty?
                clean_site_name = site.gsub(/[^\w]/, "_")[0..10]

                # Location of site installation
                if options[:location]
                    site_location = options[:location]
                else
                    site_location = ask "Where do you want to setup the site? :", :blue, default: "#{Dir.pwd}/", path: true
                end

                # Starter theme to clone
                if bare_setup
                    starter_theme = "none"
                else

                    if options[:theme]
                        starter_theme = options[:theme]
                    else
                        require "highline/import"

                        # Hash of baked-in starter themes
                        themes = {
                            "theme-juice/theme-juice-starter" => "https://github.com/ezekg/theme-juice-starter.git"
                        }

                        say "Which starter theme would you like to use? :", :blue
                        choose do |menu|
                            menu.index_suffix = ") "

                            themes.each do |theme, repo|
                                menu.choice theme do |choice|

                                    if theme == "theme-juice/theme-juice-starter"
                                        say "Awesome choice!", :green
                                    end

                                    starter_theme = choice
                                end
                            end

                            menu.choice "other" do
                                starter_theme = ask "What is the repository URL for the starter theme you would like to clone? :", :blue
                            end

                            menu.choice "none" do |choice|
                                say "Next time you want to create a site without a starter theme, you can just run the 'setup' command instead.", :yellow
                                starter_theme, bare_setup = choice, true
                            end
                        end
                    end
                end

                # Development url
                if options[:url]
                    dev_url = options[:url]
                else
                    dev_url = ask "What do you want the development url to be? (this should end in '.dev') :", :blue, default: "#{site}.dev"
                end

                unless dev_url.match /(.dev)$/
                    say "Your development url doesn't end with '.dev'. This is used within Vagrant, so that's not gonna work. Aborting mission.", :red
                    exit 1
                end

                # Initialize a git repository on setup
                if options[:skip_repo]
                    repository = false
                else
                    if options[:repository]
                        repository = options[:repository]
                    else
                        if yes? "Would you like to initialize a new Git repository? (y/N) :", :blue
                            repository = ask "What is the repository's URL? :", :blue
                        else
                            repository = false
                        end
                    end
                end

                # Database host
                if options[:skip_db]
                    db_host = "vvv"
                else
                    db_host = ask "Database host :", :blue, default: "vvv"
                end

                # Database name
                if options[:skip_db]
                    db_name = "#{clean_site_name}_db"
                else
                    db_name = ask "Database name :", :blue, default: "#{clean_site_name}_db"
                end

                # Database username
                if options[:skip_db]
                    db_user = "#{clean_site_name}_user"
                else
                    db_user = ask "Database username :", :blue, default: "#{clean_site_name}_user"
                end

                # Database password
                if options[:skip_db]
                    db_pass = SecureRandom.base64
                else
                    db_pass = ask "Database password :", :blue, default: SecureRandom.base64
                end

                # Save options
                opts = {
                    site_name: site,
                    site_location: File.expand_path(site_location),
                    starter_theme: starter_theme,
                    bare_setup: bare_setup,
                    dev_location: File.expand_path("#{::ThemeJuice::Utilities.get_vvv_path}/www/tj-#{site}"),
                    dev_url: dev_url,
                    repository: repository,
                    db_host: db_host,
                    db_name: db_name,
                    db_user: db_user,
                    db_pass: db_pass,
                }

                # Verify that all the options are correct
                say "---> Site name: #{opts[:site_name]}", :green
                say "---> Site location: #{opts[:site_location]}", :green
                say "---> Starter theme: #{opts[:starter_theme]}", :green
                say "---> Development location: #{opts[:dev_location]}", :green
                say "---> Development url: http://#{opts[:dev_url]}", :green
                say "---> Initialized repository: #{opts[:repository]}", :green
                say "---> Database host: #{opts[:db_host]}", :green
                say "---> Database name: #{opts[:db_name]}", :green
                say "---> Database username: #{opts[:db_user]}", :green
                say "---> Database password: #{opts[:db_pass]}", :green

                if yes? "Do the options above look correct? (y/N) :", :blue
                    ::ThemeJuice::Executor::create opts
                else
                    say "Dang typos... aborting mission.", :red
                    exit 1
                end
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
        desc "setup [SITE]", "Setup an existing SITE in development environment"
        def setup(site = nil)
            invoke :create, [site], bare: true
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
            self.force_vvv_path?

            if yes? "Are you sure you want to delete '#{site}'? (y/N)", :red
                ::ThemeJuice::Executor::delete site, options[:restart]
            end
        end

        ###
        # List all development sites
        #
        # @return {Void}
        ###
        desc "list", "List all sites within the VVV development environment"
        def list
            self.force_vvv_path?

            ::ThemeJuice::Executor::list
        end

        ###
        # Install and setup starter theme
        #
        # @return {Void}
        ###
        desc "install", "Run installation for the starter theme"
        method_option :config, type: :string, aliases: "-c", default: nil, desc: "Force path to config file"
        def install
            ::ThemeJuice::Executor::install options[:config]
        end

        ###
        # Assets
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "watch [COMMANDS]", "Watch and compile assets"
        def watch(*commands)
            ::ThemeJuice::Executor::subcommand "#{__method__}", commands.join(" ")
        end

        ###
        # Vendor dependencies
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vendor [COMMANDS]", "Manage vendor dependencies"
        def vendor(*commands)
            ::ThemeJuice::Executor::subcommand "#{__method__}", commands.join(" ")
        end

        ###
        # Server/Deployment
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "server [COMMANDS]", "Manage deployment and migration"
        def server(*commands)
            self.force_vvv_path?

            ::ThemeJuice::Executor::subcommand "#{__method__}", commands.join(" ")
        end

        ###
        # Vagrant
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        ###
        desc "vm [COMMANDS]", "Manage virtual development environment with Vagrant"
        def vm(*commands)
            self.force_vvv_path?

            system "cd #{::ThemeJuice::Utilities.get_vvv_path} && vagrant #{commands.join(" ")}"
        end
    end
end
