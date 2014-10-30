require "fileutils"
require "pathname"
require "tempfile"

###
# Gems
###
require 'securerandom'
require "colorize"
require "artii"
require "thor"

###
# ThemeJuice
###
require_relative "theme-juice"
require_relative "theme-juice/scaffold"

###
# Subcommands
###
require_relative "theme-juice/tasks/guard"
require_relative "theme-juice/tasks/composer"
require_relative "theme-juice/tasks/vagrant"
require_relative "theme-juice/tasks/capistrano"
require_relative "theme-juice/tasks/wpcli"

module ThemeJuice

    ###
    # CLI interface to run subcommands from
    ###
    class CLI < ::Thor
        include ::Thor::Actions

        # ###
        # # Guard
        # ###
        # desc "watch", "Watch and compile assets with Guard"
        # subcommand "watch", ::ThemeJuice::Tasks::Guard
        #
        # ###
        # # Composer
        # ###
        # desc "dependencies", "Manage vendor dependencies with Composer"
        # subcommand "dependencies", ::ThemeJuice::Tasks::Composer
        #
        # ###
        # # Vagrant
        # ###
        # desc "vm", "Manage virtual development environment with Vagrant"
        # subcommand "vm", ::ThemeJuice::Tasks::Vagrant
        #
        # ###
        # # Capistrano
        # ###
        # desc "deploy", "Run deployment and migration command with Capistrano"
        # subcommand "deploy", ::ThemeJuice::Tasks::Capistrano

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
                    exit -1
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
                        exit -1
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
                        exit -1
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
        ###
        desc "create [THEME]", "Setup THEME and virtual development environment with Vagrant"
        method_option :bare, :default => nil
        def create(theme = nil)
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
                ::ThemeJuice::warning "Just a few more questions before we create `#{theme}`..."
            end

            # Ask for the theme name if not passed directly
            theme ||= ask("[?] Theme name (required):").downcase

            # Make sure theme name was given, else throw err
            unless theme.empty?

                theme_location = ask "[?] Theme location:",
                    :default => "#{Dir.pwd}/"
                dev_url = ask "[?] Development url:",
                    :default => "#{theme}.dev"
                repository = ask "[?] Git repository:",
                    :default => "none"
                db_name = ask "[?] Database name:",
                    :default => "wordpress"
                db_user = ask "[?] Database username:",
                    :default => "wordpress"
                db_pass = ask "[?] Database password:",
                    :default => SecureRandom.base64
                db_host = ask "[?] Database host:",
                    :default => dev_url

                # Ask for other options
                opts = {
                    :theme_name => theme,
                    :theme_location => File.expand_path(theme_location),
                    :bare_install => options[:bare],
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}"),
                    :dev_url => dev_url,
                    :repository => repository,
                    :db_name => db_name,
                    :db_user => db_user,
                    :db_pass => db_pass,
                    :db_host => db_host
                }

                # Create the theme!
                ::ThemeJuice::Scaffold::create opts
            else
                ::ThemeJuice::error "Theme name is required. Aborting mission."
                exit -1
            end
        end

        ###
        # Remove all traces of site from Vagrant
        #
        # @param {String} theme
        #   Theme to delete. This will not delete your local files, only the VVV env.
        ###
        desc "delete THEME", "Remove THEME from Vagrant development environment"
        method_option :restart, :default => nil
        def delete(theme)
            ::ThemeJuice::warning "This method does not remove your local theme. It will only remove the site from within the VM."

            answer = ask "Are you sure you want to delete theme `#{theme}`?",
                :limited_to => ["yes", "no"]

            if answer == "yes"
                ::ThemeJuice::Scaffold::delete theme, options[:restart]
            end
        end

        ###
        # List all development sites
        ###
        desc "list", "List all development sites within Vagrant"
        def list
            ::ThemeJuice::Scaffold::list
        end
    end
end
