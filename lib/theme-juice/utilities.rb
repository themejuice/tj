# encoding: UTF-8

module ThemeJuice
    module Utilities
        class << self
            attr_accessor :vvv_path
            attr_accessor :no_unicode
            attr_accessor :no_colors

            include ::Thor::Actions
            include ::Thor::Shell

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
                    ::ThemeJuice::UI.speak "Your version of Theme Juice (#{local_version}) is outdated. There is a newer version (#{remote_version}) available. Please update now.", {
                        color: [:black, :on_yellow],
                        icon: :arrow_right,
                        full_width: true
                    }
                else
                    ::ThemeJuice::UI.speak "Your version of Theme Juice (#{local_version}) up to date.", {
                        color: [:black, :on_green],
                        icon: :arrow_right,
                        full_width: true
                    }
                end
            end
        end
    end
end
