require "securerandom"
require "fileutils"
require "pathname"
require "tempfile"
require "thor"

require_relative "theme-juice/version"
require_relative "theme-juice/scaffold"
require_relative "theme-juice/cli"

module ThemeJuice
    class << self

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
