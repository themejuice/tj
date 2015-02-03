require "securerandom"
require "fileutils"
require "pathname"
require "tempfile"
require "rubygems"
require "thor"
require "yaml"

require_relative "theme-juice/version"
require_relative "theme-juice/executor"
require_relative "theme-juice/cli"

module ThemeJuice
    class << self
        include ::Thor::Actions
        include ::Thor::Shell

        ###
        # Get path where VVV is installed
        #
        # @return {String}
        ###
        def get_vvv_path
            ::ThemeJuice::CLI::options[:vvv_path] ||= File.expand_path "~/vagrant"
        end

        ###
        # Check if program is installed
        #
        # @note Doesn't work on Win
        #
        # @param {String} program
        #
        # @return {Bool}
        ###
        def installed?(program)
            system "which #{program} > /dev/null 2>&1"
        end

        ###
        # Check if current version is outdated
        #
        # @return {Bool}
        ###
        def check_if_current_version_is_outdated
            local_version = ::ThemeJuice::VERSION

            fetcher = ::Gem::SpecFetcher.fetcher
            dependency = ::Gem::Dependency.new "theme-juice", ">= #{local_version}"

            remotes, = fetcher.search_for_dependency dependency
            remote_version = remotes.map { |n, _| n.version }.sort.last

            if ::Gem::Version.new(local_version) < ::Gem::Version.new(remote_version)
                say "Warning: your version of theme-juice (#{local_version}) is outdated. There is a newer version (#{remote_version}) available. Please update now.", :yellow
            else
                say "Up to date.", :green
            end
        end
    end
end
