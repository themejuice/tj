# encoding: UTF-8

module ThemeJuice
    class CLI < ::Thor

        map %w[--version -v]             => :version
        map %w[new, add, build, make]    => :create
        map %w[setup, init, prep]        => :create
        map %w[remove, trash, teardown]  => :delete
        map %w[sites, show]              => :list
        map %w[assets, dev]              => :watch
        map %w[dependencies, deps]       => :vendor
        map %w[deploy, remote]           => :server
        map %w[vagrant, vvv]             => :vm

        class_option :no_unicode, type: :boolean, alias: "-nu",               desc: "Disable all unicode characters"
        class_option :no_colors,  type: :boolean, alias: "-nc",               desc: "Disable colored output"
        class_option :vvv_path,   type: :string,  alias: "-fp", default: nil, desc: "Force path to VVV installation"

        ###
        # Non-Thor commands
        ###
        no_commands do

            ###
            # Disable unicode characters if flag is passed
            #
            # @return {Void}
            ###
            def use_unicode_chars?
                ::ThemeJuice::Utilities.no_unicode = true if options[:no_unicode]
            end

            ###
            # Disable unicode characters if flag is passed
            #
            # @return {Void}
            ###
            def use_terminal_colors?
                ::ThemeJuice::Utilities.no_colors = true if options[:no_colors]
            end

            ###
            # Set VVV path
            #
            # @return {Void}
            ###
            def force_vvv_path?
                if options[:vvv_path].nil?
                    ::ThemeJuice::Utilities.vvv_path = File.expand_path("~/vagrant")
                else
                    ::ThemeJuice::Utilities.vvv_path = options[:vvv_path]
                    ::ThemeJuice::UI.notice "You're using a custom VVV path : (#{::ThemeJuice::Utilities.vvv_path})"

                    unless ::ThemeJuice::UI.agree? "Is the path correct?"
                        ::ThemeJuice::UI.error "Good call. Let's create a working dev environment, not a broken computer. Aborting mission."
                    end
                end

                unless Dir.exist? ::ThemeJuice::Utilities.vvv_path
                    ::ThemeJuice::UI.error "Cannot load VVV path (#{::ThemeJuice::Utilities.vvv_path}). Aborting mission before something bad happens."
                end
            end

            ###
            # Output welcome message
            #
            # @return {Void}
            ###
            def welcome_message
                ::ThemeJuice::UI.speak "Welcome to Theme Juice!", {
                    color: [:black, :on_green, :bold],
                    row: true
                }
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

            ::ThemeJuice::UI.speak ::ThemeJuice::VERSION, {
                color: :green,
                icon: :notice
            }
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
        method_option :bare,         type: :boolean, aliases: "-b",                 desc: "Create a VVV site without a starter theme"
        method_option :site,         type: :string,  aliases: "-s", default: false, desc: "Name of the development site"
        method_option :location,     type: :string,  aliases: "-l", default: false, desc: "Location of the local site"
        method_option :theme,        type: :string,  aliases: "-t", default: false, desc: "Starter theme to install"
        method_option :url,          type: :string,  aliases: "-u", default: false, desc: "Development URL of the site"
        method_option :repository,   type: :string,  aliases: "-r",                 desc: "Initialize a new Git remote repository"
        method_option :skip_repo,    type: :boolean,                                desc: "Skip repository prompts and use defaults"
        method_option :skip_db,      type: :boolean,                                desc: "Skip database prompts and use defaults"
        method_option :use_defaults, type: :boolean,                                desc: "Skip all prompts and use default settings"
        def create(site = nil)
            self.use_terminal_colors?
            self.use_unicode_chars?

            self.welcome_message

            self.force_vvv_path?

            if options[:site]
                site = options[:site]
            end

            # Check if user passed all required options through flags
            if options.length >= 6 || options[:use_defaults]
                ::ThemeJuice::UI.success "Well... looks like you just have everything all figured out, huh?"
            elsif site.nil?
                ::ThemeJuice::UI.speak "Just a few questions before we begin...", {
                    color: [:black, :on_green],
                    icon: :notice,
                    row: true
                }
            else
                ::ThemeJuice::UI.speak "Your site name shall be '#{site}'! Just a few more questions before we begin...", {
                    color: [:black, :on_green],
                    icon: :notice,
                    row: true
                }
            end

            # Ask for the Site name if not passed directly
            site ||= ::ThemeJuice::UI.prompt "What's the site name? (only ascii characters are allowed)"

            # Make sure site name is valid
            if site.match /[^0-9A-Za-z.\-]/
                ::ThemeJuice::UI.error "Site name contains invalid non-ascii characters. This name is used for creating directories, so that's not gonna work. Aborting mission."
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
                    if options[:use_defaults]
                        site_location = "#{Dir.pwd}/"
                    else
                        site_location = ::ThemeJuice::UI.prompt "Where do you want to setup the site?", default: "#{Dir.pwd}/", path: true
                    end
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

                        if options[:use_defaults]
                            starter_theme = themes["theme-juice/theme-juice-starter"]
                        else
                            ::ThemeJuice::UI.speak "Which starter theme would you like to use? (partial name is acceptable)", {
                                color: :blue,
                                icon: :question
                            }

                            choose do |menu|
                                menu.index = ::ThemeJuice::UI::speak "", {
                                    icon: :question,
                                    indent: 2,
                                    empty: true,
                                    quiet: true
                                }

                                menu.prompt = ::ThemeJuice::UI::speak "Choose one :", {
                                    color: :blue,
                                    icon: :question,
                                    width: 16,
                                    quiet: true
                                }

                                themes.each do |theme, repo|
                                    menu.choice theme do

                                        if theme == "theme-juice/theme-juice-starter"
                                            ::ThemeJuice::UI.success "Awesome choice!"
                                        end

                                        starter_theme = repo
                                    end
                                end

                                menu.choice "other" do
                                    starter_theme = ::ThemeJuice::UI.prompt "What is the repository URL for the starter theme you would like to clone?", indent: 2
                                end

                                menu.choice "none" do |opt|
                                    ::ThemeJuice::UI.notice "Next time you need to create a site without a starter theme, you can just run the 'setup' command instead."
                                    starter_theme, bare_setup = opt, true
                                end
                            end
                        end
                    end
                end

                # Development url
                if options[:url]
                    dev_url = options[:url]
                else
                    if options[:use_defaults]
                        dev_url = "#{site}.dev"
                    else
                        dev_url = ::ThemeJuice::UI.prompt "What do you want the development url to be? (this should end in '.dev')", default: "#{site}.dev"
                    end
                end

                unless dev_url.match /(.dev)$/
                    ::ThemeJuice::UI.error "Your development url doesn't end with '.dev'. This is used within Vagrant, so that's not gonna work. Aborting mission."
                end

                # Initialize a git repository on setup
                if options[:repository]
                    repository = options[:repository]
                else
                    if options[:use_defaults] || options[:skip_repo]
                        repository = false
                    else
                        if ::ThemeJuice::UI.agree? "Would you like to initialize a new Git repository?"
                            repository = ::ThemeJuice::UI.prompt "What is the repository's URL?", indent: 2
                        else
                            repository = false
                        end
                    end
                end

                # Database host
                if options[:use_defaults] || options[:skip_db]
                    db_host = "vvv"
                else
                    db_host = ::ThemeJuice::UI.prompt "Database host", default: "vvv"
                end

                # Database name
                if options[:use_defaults] || options[:skip_db]
                    db_name = "#{clean_site_name}_db"
                else
                    db_name = ::ThemeJuice::UI.prompt "Database name", default: "#{clean_site_name}_db"
                end

                # Database username
                if options[:use_defaults] || options[:skip_db]
                    db_user = "#{clean_site_name}_user"
                else
                    db_user = ::ThemeJuice::UI.prompt "Database username", default: "#{clean_site_name}_user"
                end

                # Database password
                if options[:use_defaults] || options[:skip_db]
                    db_pass = SecureRandom.base64
                else
                    db_pass = ::ThemeJuice::UI.prompt "Database password", default: SecureRandom.base64
                end

                # Save options
                opts = {
                    site_name: site,
                    site_location: File.expand_path(site_location),
                    starter_theme: starter_theme,
                    bare_setup: bare_setup,
                    dev_location: File.expand_path("#{::ThemeJuice::Utilities.vvv_path}/www/tj-#{site}"),
                    dev_url: dev_url,
                    repository: repository,
                    db_host: db_host,
                    db_name: db_name,
                    db_user: db_user,
                    db_pass: db_pass,
                }

                # Verify that all the options are correct
                ::ThemeJuice::UI.list "Your settings :", :yellow, [
                    "Site name: #{opts[:site_name]}",
                    "Site location: #{opts[:site_location]}",
                    "Starter theme: #{opts[:starter_theme]}",
                    "Development location: #{opts[:dev_location]}",
                    "Development url: http://#{opts[:dev_url]}",
                    "Initialized repository: #{opts[:repository]}",
                    "Database host: #{opts[:db_host]}",
                    "Database name: #{opts[:db_name]}",
                    "Database username: #{opts[:db_user]}",
                    "Database password: #{opts[:db_pass]}"
                ]

                if ::ThemeJuice::UI.agree? "Do the options above look correct?"
                    ::ThemeJuice::Executor::create opts
                else
                    ::ThemeJuice::UI.error "Dang typos... aborting mission."
                end
            else
                ::ThemeJuice::UI.error "Site name is required. Aborting mission."
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
        method_option :restart, type: :boolean, alias: "-r", desc: "Restart development environment after SITE deletion"
        def delete(site)
            self.use_terminal_colors?
            self.use_unicode_chars?
            self.force_vvv_path?

            ::ThemeJuice::UI.speak "Are you sure you want to delete '#{site}'? (y/N)", {
                color: [:white, :on_red],
                icon: :notice,
                row: true
            }

            if ::ThemeJuice::UI.agree? "", { color: :red, simple: true }
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
            self.use_terminal_colors?
            self.use_unicode_chars?
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
            self.use_terminal_colors?
            self.use_unicode_chars?

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
            self.use_terminal_colors?
            self.use_unicode_chars?

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
            self.use_terminal_colors?
            self.use_unicode_chars?

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
            self.use_terminal_colors?
            self.use_unicode_chars?
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
            self.use_terminal_colors?
            self.use_unicode_chars?
            self.force_vvv_path?

            system "cd #{::ThemeJuice::Utilities.vvv_path} && vagrant #{commands.join(" ")}"
        end
    end
end
