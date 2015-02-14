# encoding: UTF-8

module ThemeJuice
    module Interaction

        # Unicode icons
        SUCCESS       = "\u2713"
        ERROR         = "\u2191"
        NOTICE        = "\u2192"
        QUESTION      = "\u2022"
        GENERAL       = "\u2022"
        RESTART       = "\u21AA"
        SELECTED      = "\u2022"
        UNSELECTED    = "\u25CB"

        # Fallback icons
        NU_SUCCESS    = "+"
        NU_ERROR      = "!"
        NU_NOTICE     = "-"
        NU_QUESTION   = "?"
        NU_GENERAL    = "-"
        NU_RESTART    = "!"
        NU_SELECTED   = "[x]"
        NU_UNSELECTED = "[ ]"

        # Get the environment
        @environment = ::ThemeJuice::Environment

        class << self
            include ::Thor::Actions
            include ::Thor::Shell

            #
            # Output formatted message to terminal
            #
            # @param {String} message
            # @param {Hash}   opts
            #
            # @return {Void}
            #
            def speak(message, opts = {})
                format_message! message, opts
                output_message
            end

            #
            # Ask a question
            #
            # @param {String} question
            # @param {Hash}   opts
            #
            # @return {Void}
            #
            def prompt(question, *opts)
                format_message! question, {
                    color: :blue,
                    icon: :question
                }

                opts.each do |opt|
                    if opt.respond_to? :key?

                        # if opt.key? :default
                        #     opt[:default] = set_color(opt[:default], :black, :bold) unless @environment.no_colors
                        # end

                        if opt.key? :indent
                            set!(question) { |str| (" " * opt[:indent]) << str }
                        end
                    end

                    break
                end

                ask("#{question} :", *opts).gsub /\e\[\d+m/, ""
            end

            #
            # Ask a yes or no question
            #
            # @param {String} question
            # @param {Hash}   opts
            #
            # @return {Bool}
            #
            def agree?(question, opts = {})

                unless opts.key? :color
                    opts[:color] = :blue
                end

                format_message! question, {
                    color: opts[:color],
                    icon: :question
                }

                if opts.key? :simple
                    yes? " :", if opts.key? :color then opts[:color] end
                else
                    yes? "#{question} (y/N) :"
                end
            end

            #
            # Output success message
            #
            # @param {String} message
            #
            # @return {Void}
            #
            def success(message)
                speak message, {
                    color: [:black, :on_green, :bold],
                    icon: :success,
                    row: true
                }
            end

            #
            # Output notice message
            #
            # @param {String} message
            #
            # @return {Void}
            #
            def notice(message)
                speak message, {
                    color: [:black, :on_yellow],
                    icon: :notice,
                    row: true
                }
            end

            #
            # Output error message and exit. Allows a block to be passed
            #  as well, which will be executed before exiting
            #
            # @param {String} message
            #
            # @return {Void}
            #
            def error(message)
                speak message, {
                    color: [:white, :on_red],
                    icon: :error,
                    row: true
                }

                yield if block_given?

                exit 1
            end

            #
            # Output a list of messages
            #
            # @param {String} header
            # @param {Symbol} color
            # @param {Array}  list
            #
            # @return {Void}
            #
            def list(header, color, list)
                speak header, {
                    color: [:black, :"on_#{color}"],
                    icon: :notice,
                    row: true
                }

                list.each do |item|
                    speak item, {
                        color: :"#{color}",
                        icon: :general
                    }
                end
            end

            #
            # Create a shell select menu
            #
            # @param {String} header
            # @param {Symbol} color
            # @param {Array}  list
            #
            # @return {String}
            #
            def choose(header, color, list)
                speak "#{header} (use arrow keys and press enter)", {
                    color: :"#{color}",
                    icon: :question
                }

                print "\n" * list.size

                selected = 0
                update_list_selection(list, color, selected)

                loop do
                    case chr = read_key
                    # Up
                    when "\e[A"
                        selected -= 1
                        selected = list.size - 1 if selected < 0
                        update_list_selection(list, color, selected)
                    # Down
                    when "\e[B"
                        selected += 1
                        selected = 0 if selected > list.size - 1
                        update_list_selection(list, color, selected)
                    # Enter
                    when "\r", "\n"
                        return list[selected]
                    # Ctrl+C, Esc
                    when "\u0003", "\e"
                        exit 130
                    # else
                    #     speak "You pressed: #{chr.inspect}", { color: :yellow }
                    end
                end
            end

            private

            #
            # Destructively format message
            #
            # @param {String} message
            # @param {Hash}   opts
            #
            # @return {String}
            #
            def format_message!(message, opts = {})
                @message, @opts = message, opts

                steps = ["icon", "newline", "row", "width", "color", "indent"]
                steps.each { |step| send "format_message_#{step}!" unless @opts[:"#{step}"].nil? }

                @message
            end

            #
            # Run destructive block against string
            #
            # @param {String} string
            #
            # @return {String}
            #
            def set!(string)
                str = yield(string); string.clear; string << str
            end

            #
            # Force message to use icon (if environment allows)
            #
            # @return {String}
            #
            def format_message_icon!
                icon = if @environment.no_unicode then "nu_#{@opts[:icon]}" else "#{@opts[:icon]}" end

                if @opts.key? :icon
                    set!(@message) { |msg| " #{const_get(icon.to_s.upcase)}" << if @opts.key? :empty then nil else " #{msg}" end }
                else
                    set!(@message) { |msg| " " << msg }
                end
            end

            #
            # Force message on newline
            #
            # @return {String}
            #
            def format_message_newline!
                set!(@message) { |msg| "\n" << msg }
            end

            #
            # Force message to use colors (if environment allows)
            #
            # @return {String}
            #
            def format_message_color!
                set!(@message) { |msg| set_color(msg, *@opts[:color]) } unless @environment.no_colors
            end

            #
            # Force message to take up width of terminal window
            #
            # @return {String}
            #
            def format_message_row!
                set!(@message) { |msg| msg.ljust(terminal_width) }
            end

            #
            # Force message width
            #
            # @return {String}
            #
            def format_message_width!
                set!(@message) { |msg| msg.ljust(@opts[:width]) }
            end

            #
            # Force message indentation
            #
            # @return {String}
            #
            def format_message_indent!
                set!(@message) { |str| (" " * @opts[:indent]) << str }
            end

            #
            # Output message to terminal, unless quiet
            #
            # @return {String|Void}
            #
            def output_message
                if @opts.key? :quiet then @message else say @message end
            end

            #
            # Output list with updated selection
            #
            # @return {Void}
            #
            def update_list_selection(list, color, selected = 0)
                print "\e[#{list.size}A"

                list.each_with_index do |item, i|
                    icon = if i == selected then "selected" else "unselected" end
                    speak "#{item}", {
                        color: :"#{color}",
                        icon: :"#{icon}",
                        indent: 2
                    }
                end
            end

            #
            # Read input
            #
            # @return {String}
            #
            def read_key
                save_mode
                raw_no_echo_mode

                chr = STDIN.getc

                # Make sure we can still exit
                if chr == "\e"
                    thread = Thread.new { chr += STDIN.getc + STDIN.getc }.join(1).kill
                end

                chr
            ensure
                restore_mode
            end

            #
            # Get the current state
            #
            def save_mode
                @state = %x(stty -g)
            end

            #
            # Disable processing and output of all input
            #
            def raw_no_echo_mode
                %x(stty raw -echo)
            end

            #
            # Restore state
            #
            def restore_mode
                %x(stty #{@state})
            end
        end
    end
end
