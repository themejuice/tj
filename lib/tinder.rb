module Tinder
    class << self

        ###
        # Outputs colorized message to command line
        #
        # @param {String} message
        # @param {String} color
        ###
        def message(message, color)
            puts "#{message}".send "#{color}"
        end

        ###
        # Success message
        ###
        def success(message)
            message message, "green"
        end

        ###
        # Warning message
        ###
        def warning(message)
            message message, "yellow"
        end

        ###
        # Error message
        ###
        def error(message)
            message message, "red"
        end

        ###
        # Check if program is installed
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
