# encoding: UTF-8

module ThemeJuice
    class CLI < Thor

        #
        # Command aliases
        #
        map %w[--version -v]             => :version
        map %w[new, add, build, make]    => :create
        map %w[prep]                     => :setup
        map %w[remove, trash, teardown]  => :delete
        map %w[sites, show]              => :list
        map %w[assets, dev]              => :watch
        map %w[dependencies, deps]       => :vendor
        map %w[deploy, remote]           => :server
        map %w[vagrant, vvv]             => :vm

        #
        # Class options
        #
        class_option :vvv_path,      type: :string,  aliases: "-fp", default: nil, desc: "Force path to VVV installation"
        class_option :yolo,          type: :boolean, aliases: "-y",                desc: "Say yes to anything and everything"
        class_option :boring,        type: :boolean, aliases: "-b",                desc: "Disable all the coolness"
        class_option :no_unicode,    type: :boolean, aliases: "-nu",               desc: "Disable all unicode characters"
        class_option :no_colors,     type: :boolean, aliases: "-nc",               desc: "Disable all colored output"
        class_option :no_animations, type: :boolean, aliases: "-na",               desc: "Disable all animations"

        desc "--version, -v", "Print current version"
        #
        # Print current version
        #
        # @return {String}
        #
        def version
            self.set_environment

            @interaction.speak ::ThemeJuice::VERSION, { color: :green }
        end

        desc "create", "Create new site and setup VVV environment"
        method_option :bare,         type: :boolean, aliases: "-b",                 desc: "Create a VVV site without a starter theme"
        method_option :site,         type: :string,  aliases: "-s", default: false, desc: "Name of the development site"
        method_option :location,     type: :string,  aliases: "-l", default: false, desc: "Location of the local site"
        method_option :theme,        type: :string,  aliases: "-t", default: false, desc: "Starter theme to install"
        method_option :url,          type: :string,  aliases: "-u", default: false, desc: "Development URL of the site"
        method_option :repository,   type: :string,  aliases: "-r",                 desc: "Initialize a new Git remote repository"
        method_option :skip_repo,    type: :boolean,                                desc: "Skip repository prompts and use defaults"
        method_option :skip_db,      type: :boolean,                                desc: "Skip database prompts and use defaults"
        method_option :use_defaults, type: :boolean,                                desc: "Skip all prompts and use default settings"
        #
        # Install and setup VVV environment with new site
        #
        # @param {String} site (nil)
        #   Name of the site to create
        #
        # @return {Void}
        #
        def create(site = nil)
            self.set_environment
            @interaction.hello

            opts = {
                site_bare:          options[:bare],
                site_name:          site || options[:site],
                site_location:      options[:location],
                site_starter_theme: options[:theme],
                site_dev_location:  nil,
                site_dev_url:       options[:url],
                site_repository:    options[:repository],
                skip_repo:          options[:skip_repo],
                skip_db:            options[:skip_db],
                use_defaults:       options[:use_defaults]
            }

            ::ThemeJuice::Command::Create.new(opts)
        end

        desc "setup [SITE]", "Setup an existing SITE in development environment"
        #
        # Setup an existing WordPress install in VVV
        #
        # @param {String} site (nil)
        #   Name of the site to setup
        #
        # @return {Void}
        #
        method_option :site,         type: :string,  aliases: "-s", default: false, desc: "Name of the development site"
        method_option :location,     type: :string,  aliases: "-l", default: false, desc: "Location of the local site"
        method_option :url,          type: :string,  aliases: "-u", default: false, desc: "Development URL of the site"
        method_option :repository,   type: :string,  aliases: "-r",                 desc: "Initialize a new Git remote repository"
        method_option :skip_repo,    type: :boolean,                                desc: "Skip repository prompts and use defaults"
        method_option :skip_db,      type: :boolean,                                desc: "Skip database prompts and use defaults"
        method_option :use_defaults, type: :boolean,                                desc: "Skip all prompts and use default settings"
        def setup(site = nil)
            self.set_environment
            @interaction.hello

            opts = {
                site_bare:          true,
                site_name:          site || options[:site],
                site_location:      options[:location],
                site_starter_theme: false,
                site_dev_location:  nil,
                site_dev_url:       options[:url],
                site_repository:    options[:repository],
                skip_repo:          options[:skip_repo],
                skip_db:            options[:skip_db],
                use_defaults:       options[:use_defaults]
            }

            ::ThemeJuice::Command::Create.new(opts)
        end

        desc "delete SITE", "Remove SITE from the VVV development environment (does not remove local site)"
        method_option :site,    type: :string,  aliases: "-s", default: false, desc: "Name of the development site"
        method_option :restart, type: :boolean, aliases: "-r",                 desc: "Restart development environment after SITE deletion"
        #
        # Remove all traces of site from Vagrant
        #
        # @param {String} site (nil)
        #   Site to delete. This will not delete your local files, only
        #   files within the VVV environment.
        #
        # @return {Void}
        #
        def delete(site = nil)
            self.set_environment

            opts = {
                site_name:         site || options[:site],
                site_dev_location: nil,
                restart:           options[:restart]
            }

            ::ThemeJuice::Command::Delete.new(opts)
        end

        desc "list", "List all sites within the VVV development environment"
        #
        # List all development sites
        #
        # @return {Void}
        #
        def list
            self.set_environment

            ::ThemeJuice::Command::List.new
        end

        desc "install", "Run installation for the starter theme"
        method_option :config, type: :string, aliases: "-c", default: nil, desc: "Force path to config file"
        #
        # Install and setup starter theme
        #
        # @return {Void}
        #
        def install
            self.set_environment

            ::ThemeJuice::Command::Install.new
        end

        #
        # Assets
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        #
        desc "watch [COMMANDS]", "Watch and compile assets"
        def watch(*commands)
            self.set_environment

            opts = {
                subcommand: "watch",
                commands: commands.join(" ")
            }

            ::ThemeJuice::Command::Subcommand.new(opts)
        end

        #
        # Vendor dependencies
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        #
        desc "vendor [COMMANDS]", "Manage vendor dependencies"
        def vendor(*commands)
            self.set_environment

            opts = {
                subcommand: "vendor",
                commands: commands.join(" ")
            }

            ::ThemeJuice::Command::Subcommand.new(opts)
        end

        #
        # Server/Deployment
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        #
        desc "server [COMMANDS]", "Manage deployment and migration"
        def server(*commands)
            self.set_environment

            opts = {
                subcommand: "server",
                commands: commands.join(" ")
            }

            ::ThemeJuice::Command::Subcommand.new(opts)
        end

        #
        # Vagrant
        #
        # @param {*} commands
        #   Commands to run
        #
        # @return {Void}
        #
        desc "vm [COMMANDS]", "Manage virtual development environment with Vagrant"
        def vm(*commands)
            self.set_environment

            system "cd #{@environment.vvv_path} && vagrant #{commands.join(" ")}"
        end

        #
        # Non-Thor commands
        #
        no_commands do

            #
            # Set up the environment
            #
            # @return {Void}
            #
            def set_environment
                @environment = ::ThemeJuice::Environment
                @interaction = ::ThemeJuice::Interaction

                @environment.no_colors     = if self.boring? then true else options[:no_colors]     end
                @environment.no_unicode    = if self.boring? then true else options[:no_unicode]    end
                @environment.no_animations = if self.boring? then true else options[:no_animations] end

                self.force_vvv_path?
                self.yolo?
            end

            #
            # Enable boring-mode
            #
            # @return {Bool}
            #
            def boring?
                @environment.boring = options[:boring]
            end

            #
            # Enable yolo-mode
            #
            # @return {Bool}
            #
            def yolo?
                @environment.yolo = options[:yolo]
            end

            #
            # Set VVV path
            #
            # @return {Void}
            #
            def force_vvv_path?
                if options[:vvv_path].nil?
                    @environment.vvv_path = File.expand_path("~/vagrant")
                else
                    @environment.vvv_path = options[:vvv_path]
                    @interaction.notice "You're using a custom VVV path : (#{@environment.vvv_path})"

                    unless @interaction.agree? "Is the path correct?"
                        @interaction.error "Good call. Let's create things, not break things. Aborting mission."
                    end
                end

                unless Dir.exist? @environment.vvv_path
                    @interaction.error "Cannot load VVV path (#{@environment.vvv_path}). Aborting mission before something bad happens."
                end
            end
        end
    end
end
