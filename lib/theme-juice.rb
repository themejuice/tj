require "securerandom"
require "fileutils"
require "pathname"
require "tempfile"
require "thor"
require "yaml"

require_relative "theme-juice/version"
require_relative "theme-juice/executor"
require_relative "theme-juice/cli"

module ThemeJuice
    class << self

        ###
        # Get path where VVV is installed
        #
        # @return {String}
        ###
        def vvv_path
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
    end
end
