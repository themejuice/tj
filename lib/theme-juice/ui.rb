# encoding: UTF-8

module ThemeJuice
    module UI

        QUESTION_MARK = "?"
        BULLET_HOLLOW = "\u25CB"
        BULLET_SOLID  = "\u2022"
        ARROW_UP      = "\u2191"
        ARROW_RIGHT   = "\u2192"
        ARROW_DOWN    = "\u2193"
        ARROW_LEFT    = "\u2190"
        ARROW_RELOAD  = "\u21AA"
        BLOCK_LARGE   = "\u2588"
        BLOCK_MED     = "\u258D"
        BLOCK_SMALL   = "\u258F"

        class << self
            include ::Thor::Actions
            include ::Thor::Shell

            ###
            # Output formatted message to terminal
            #
            # @param {String} message
            # @param {Hash}   opts
            #
            # @return {Void}
            ###
            def speak(message, opts = {})
                format_message! message, opts

                # Check if we're suppressing terminal output
                if opts.key? :suppress
                    message
                else
                    say message
                end
            end

            ###
            # Output success message
            #
            # @param {String} message
            #
            # @return {Void}
            ###
            def success(message)
                self.speak message, {
                    color: [:black, :on_green, :bold],
                    full_width: true
                }
            end

            ###
            # Output notice message
            #
            # @param {String} message
            #
            # @return {Void}
            ###
            def notice(message)
                self.speak message, {
                    color: [:black, :on_yellow],
                    icon: :arrow_right,
                    full_width: true
                }
            end

            ###
            # Output error message and exit. Allows a block to be passed
            #  as well, which will be executed before exiting
            #
            # @param {String} message
            #
            # @return {Void}
            ###
            def error(message)
                self.speak message, {
                    color: [:white, :on_red],
                    icon: :arrow_up,
                    full_width: true
                }

                yield if block_given?

                exit 1
            end

            ###
            # Output a list of messages
            #
            # @param {String} header
            # @param {Symbol} color
            # @param {Array}  list
            #
            # @return {Void}
            ###
            def list(header, color, list)
                self.speak header, {
                    color: [:black, :"on_#{color}"],
                    icon: :arrow_right,
                    full_width: true
                }

                list.each do |item|
                    self.speak item, {
                        color: :"#{color}",
                        icon: :bullet_solid
                    }
                end
            end

            ###
            # Ask a question
            #
            # @param {String} question
            # @param {Hash}   opts
            #
            # @return {Void}
            ###
            def prompt(question, *opts)
                format_message! question, {
                    color: :blue,
                    icon: :bullet_hollow
                }

                opts.each do |opt|
                    if opt.respond_to? :key?

                        # if opt.key? :default
                        #     opt[:default] = set_color(opt[:default], :black, :bold)
                        # end

                        if opt.key? :indent
                            set!(question) { |str| (" " * opt[:indent]) << str }
                        end
                    end

                    break
                end

                ask "#{question} :", *opts
            end

            ###
            # Ask a yes or no question
            #
            # @param {String} question
            # @param {Hash}   opts
            #
            # @return {Bool}
            ###
            def agree?(question, opts = {})

                unless opts.key? :color
                    opts[:color] = :blue
                end

                format_message! question, {
                    color: opts[:color],
                    icon: :bullet_hollow
                }

                if opts.key? :simple
                    yes? " :", if opts.key? :color then opts[:color] end
                else
                    yes? "#{question} (y/N) :"
                end
            end

            private

            ###
            # Destructively format message
            #
            # @param {String} message
            # @param {Hash}   opts
            #
            # @return {String}
            ###
            def format_message!(message, opts = {})

                # Check if we're using an icon
                unless ::ThemeJuice::Utilities.no_unicode
                    if opts.key? :icon
                        set!(message) { |msg| " #{self.const_get(opts[:icon].to_s.upcase)} " << msg if opts[:icon].is_a? Symbol }
                    else
                        set!(message) { |msg| " " << msg }
                    end
                end

                # Check if message should take up entire width
                #  of the terminal window
                if opts.key? :full_width
                    set!(message) { |msg| msg.ljust(terminal_width) }
                end

                # Check if we're using colors
                unless ::ThemeJuice::Utilities.no_colors
                    if opts.key? :color
                        set!(message) { |msg| set_color(msg, *opts[:color]) }
                    end
                end

                message
            end

            ###
            # Run destructive block against message
            #
            # @return {String}
            ###
            def set!(string)
                str = yield(string); string.clear; string << str
            end
        end
    end
end
