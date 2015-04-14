# encoding: UTF-8

module ThemeJuice
  module Interact

    # Unicode icons
    ICONS = {
      :success             => "\u2713",
      :error               => "\u2191",
      :notice              => "\u2192",
      :question            => "\u2022",
      :general             => "\u2022",
      :log                 => "\u2026",
      :restart             => "\u21AA",
      :selected            => "\u2022",
      :unselected          => "\u25CB",
      :fallback_success    => "+",
      :fallback_error      => "!",
      :fallback_notice     => "-",
      :fallback_question   => "?",
      :fallback_general    => "-",
      :fallback_log        => "...",
      :fallback_restart    => "!",
      :fallback_selected   => "[x]",
      :fallback_unselected => "[ ]",
    }

    # Escape sequences
    KEYS = {
      "\e[A" => "up",
      "\e[B" => "down",
      "\e[C" => "right",
      "\e[D" => "left",
      "\003" => "ctrl+c",
      "\004" => "ctrl+d",
      "\e"   => "escape",
      "\n"   => "linefeed",
      "\r"   => "return",
      " "    => "space",
    }

    # Get the environment
    @env = ::ThemeJuice::Env

    class << self
      include ::Thor::Actions
      include ::Thor::Shell

      #
      # Output formatted message
      #
      # @param {String} message
      # @param {Hash}   opts
      #
      # @return {Void}
      #
      def speak(message, opts = {})
        format_message message, opts
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
        format_message question, {
          :color => :blue,
          :icon  => :question
        }

        opts.each do |opt|

          # if opt[:default]
          #   opt[:default] = set_color(opt[:default], :black, :bold) unless @env.no_colors
          # end

          if opt[:indent]
            set(question) { |str| (" " * opt[:indent]) << str }
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
        format_message question, {
          :color => opts[:color] || :blue,
          :icon  => :question
        }

        if opts[:simple]
          yes? " :", if opts[:color] then opts[:color] end
        else
          yes? "#{question} (y/N) :"
        end
      end

      #
      # Output log message
      #
      # @param {String} message
      #
      # @return {Void}
      #
      def log(message)
        speak message, {
          :color => :yellow,
          :icon  => :log
        }
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
          :color => [:black, :on_green, :bold],
          :icon  => :success,
          :row   => true
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
          :color => [:black, :on_yellow],
          :icon  => :notice,
          :row   => true
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
          :color => [:white, :on_red],
          :icon  => :error,
          :row   => true
        }

        yield if block_given?

        exit 1
      end

      #
      # Output greeting
      #
      # @param {Hash} opts ({})
      #
      # @return {Void}
      #
      def hello(opts = {})
        speak "Welcome to Theme Juice!", {
          :color => [:black, :on_green, :bold],
          :row   => true
        }.merge(opts)
      end

      #
      # Output goodbye and exit with interupt code
      #
      # @param {Hash} opts ({})
      #
      # @return {Void}
      #
      def goodbye(opts = {})

        # Have some fun?
        goodbyes = [
          "Bye, bye, bye",
          "Adios, muchachos",
          "See ya later, alligator",
          "Peace...",
          "Later, homes",
          "May the force be with you",
          "Take a break, man...",
          "Go home, developer, you're drunk",
          "Okay, this is getting a little out of hand...",
          "I don't like it when you press my buttons",
          "Ouch!",
          ":(",
        ]

        speak goodbyes.sample, {
          :color   => :yellow,
          :newline => true
        }.merge(opts)

        exit 130
      end

      #
      # Open project url in users default browser
      #
      # @param {String} url
      #
      # @return {Void}
      #
      def open_project(url)
        speak "Do you want to open up your new project at 'http://#{url}' now? (y/N)", {
          :color => [:black, :on_blue],
          :icon  => :restart,
          :row   => true
        }

        if agree? "", { :simple => true }
          run ["open http://#{url}"]
        end
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
          :color => [:black, :"on_#{color}"],
          :icon  => :notice,
          :row   => true
        }

        list.each do |item|
          speak item, {
            :color => :"#{color}",
            :icon  => :general
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
          :color => :"#{color}",
          :icon  => :question
        }

        print "\n" * list.size

        selected = 0
        update_list_selection(list, color, selected)

        loop do
          case key = read_key
          when "up"
            selected -= 1
            selected = list.size - 1 if selected < 0
            update_list_selection(list, color, selected)
          when "down"
            selected += 1
            selected = 0 if selected > list.size - 1
            update_list_selection(list, color, selected)
          when "return", "linefeed", "space"
            return list[selected]
          when "esc", "ctrl+c"
            goodbye(:newline => false)
          # else
          #   speak key.inspect, { :color => :yellow }
          end
        end
      end

      private

      #
      # Output list with updated selection
      #
      # @return {Void}
      #
      def update_list_selection(list, color, selected = 0)
        print "\e[#{list.size}A"

        list.each_with_index do |item, i|
          icon = i == selected ? "selected" : "unselected"
          speak "#{item} - #{i}, #{selected}", {
            :color  => :"#{color}",
            :icon   => :"#{icon}",
            :indent => 2
          }
        end
      end

      #
      # Read input
      #
      # @see http://www.alecjacobson.com/weblog/?p=75
      #
      # @return {String}
      #
      def read_key
        save_state
        raw_no_echo_mode

        key = STDIN.getc.chr

        if key == "\e"
          thread = Thread.new { key += STDIN.getc.chr + STDIN.getc.chr }
          thread.join(0.001)
          thread.kill
        end

        KEYS[key] || key
      ensure
        restore_state
      end

      #
      # Get the current state of stty
      #
      def save_state
        @state = %x(stty -g)
      end

      #
      # Disable echoing and enable raw mode
      #
      def raw_no_echo_mode
        %x(stty raw -echo)
      end

      #
      # Restore state of stty
      #
      def restore_state
        %x(stty #{@state})
      end

      #
      # Destructively format message
      #
      # @param {String} message
      # @param {Hash}   opts
      #
      # @return {String}
      #
      def format_message(message, opts = {})
        @message, @opts = message, opts

        format_message_icon
        format_message_newline
        format_message_row
        format_message_width
        format_message_color
        format_message_indent

        @message
      end

      #
      # Run destructive block against string
      #
      # @param {String} string
      #
      # @return {String}
      #
      def set(string)
        str = yield(string); string.clear; string << str
      end

      #
      # Force message to use icon (if environment allows)
      #
      # @return {String}
      #
      def format_message_icon
        icon = @env.no_unicode ? "fallback_#{@opts[:icon]}" : "#{@opts[:icon]}"

        if @opts[:icon]
          set(@message) { |msg| "#{ICONS[:"#{icon}"]}" << (@opts[:empty] ? nil : " #{msg}") }
        else
          set(@message) { |msg| "" << msg }
        end
      end

      #
      # Force message on newline, unless already on newline
      #
      # @return {String}
      #
      def format_message_newline
        set(@message) { |msg| "\n" << msg } if @opts[:newline]
      end

      #
      # Force message to use colors (if environment allows)
      #
      # @return {String}
      #
      def format_message_color
        unless @env.no_colors
          set(@message) { |msg| set_color(msg, *@opts[:color]) } if @opts[:color]
        end
      end

      #
      # Force message to take up width of terminal window
      #
      # @return {String}
      #
      def format_message_row
        set(@message) { |msg| msg.ljust(terminal_width) } if @opts[:row]
      end

      #
      # Force message width
      #
      # @return {String}
      #
      def format_message_width
        set(@message) { |msg| msg.ljust(@opts[:width]) } if @opts[:width]
      end

      #
      # Force message indentation
      #
      # @return {String}
      #
      def format_message_indent
        set(@message) { |str| (" " * @opts[:indent]) << str } if @opts[:indent]
      end

        #
        # Output message to terminal, unless quiet
        #
        # @return {String|Void}
        #
      def output_message
        @opts[:quiet] ? @message : say(@message)
      end
    end
  end
end
