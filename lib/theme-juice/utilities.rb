module ThemeJuice
    module Utilities
        class << self
            include ::Thor::Actions
            include ::Thor::Shell

            @@vvv_path ||= File.expand_path("~/vagrant")

            ###
            # Set path to VVV installation
            #
            # @param {String} path
            #
            # @return {String}
            ###
            def set_vvv_path(path)
                @@vvv_path = File.expand_path(path)
            end

            ###
            # Get path to VVV installation
            #
            # @return {String}
            ###
            def get_vvv_path
                
                unless @@vvv_path
                    say "Cannot load VVV path. Aborting mission before something bad happens.", :red
                    exit 1
                end

                @@vvv_path
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
end
