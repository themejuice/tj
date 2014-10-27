require "pathname"
require "fileutils"
require "tempfile"
require "colorize"
require "thor"

###
# Module
###
require_relative "tinder"

###
# Subcommands
###
require_relative "tinder/scaffold"
require_relative "tinder/tasks/guard"
require_relative "tinder/tasks/composer"
require_relative "tinder/tasks/vagrant"
require_relative "tinder/tasks/capistrano"

module Tinder

    ###
    # CLI interface to run subcommands from
    ###
    class CLI < ::Thor
        include ::Thor::Actions

        ###
        # Guard
        ###
        desc "watch", "Watch and compile assets with Guard"
        subcommand "watch", ::Tinder::Tasks::Guard

        ###
        # Composer
        ###
        desc "dependencies", "Manage vendor dependencies with Composer"
        subcommand "dependencies", ::Tinder::Tasks::Composer

        ###
        # Vagrant
        ###
        desc "vm", "Manage virtual development environment with Vagrant"
        subcommand "vm", ::Tinder::Tasks::Vagrant

        ###
        # Capistrano
        ###
        desc "deploy", "Run deployment and migration command with Capistrano"
        subcommand "deploy", ::Tinder::Tasks::Capistrano

        ###
        # Install and setup VVV environment
        #
        # It will automagically set up your entire development environment, including
        #   a local development site at `http://site.dev` with WordPress installed
        #   and with a fresh WP database. It will also sync up your current theme
        #   folder with the theme folder on the Vagrant VM. This task will also
        #   install and configure Vagrant/VVV into your `~/` directory.
        ###
        desc "create", "Setup new theme and virtual development environment with Vagrant"
        method_option :bare
        def create
            ::Tinder::warning "Just a few questions before we begin..."

            # Ask for the theme name
            theme = ask("[?] Theme name (required):").downcase

            # Make sure theme name was given, else throw err
            unless theme.empty?

                # Ask for other options
                opts = {
                    :theme_name => theme,
                    :theme_location => File.expand_path(ask("[?] Theme location (e.g. /path/to/site):", :default => Dir.pwd)),
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}"),
                    :dev_url => ask("[?] Development url (e.g. site.dev):", :default => "#{theme}.dev"),
                    :db_name => ask("[?] Database name:", :default => theme.gsub(/[^\w]/, "_")).gsub(/[^\w]/, "_"),
                    :db_user => ask("[?] Database username:", :default => theme.gsub(/[^\w]/, "_")).gsub(/[^\w]/, "_"),
                    :db_pass => ask("[?] Database password:", :default => theme),
                    :db_host => ask("[?] Database host:", :default => "192.168.50.4")
                }

                # Create the theme!
                ::Tinder::Scaffold::create opts
            else
                ::Tinder::error "Theme name is required. Aborting mission."
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
        method_option :restart, :default => true
        def delete(theme)
            ::Tinder::Scaffold::delete theme, options[:restart]
        end
    end
end
