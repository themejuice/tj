# encoding: UTF-8

module ThemeJuice
  module IO
    include Thor::Shell

    ICONS = {
      :success             => "✓", # "\u2713",
      :error               => "↑", # "\u2191",
      :notice              => "→", # "\u2192",
      :question            => "•", # "\u2022",
      :general             => "›", # "\u203A",
      :log                 => "…", # "\u2026",
      :restart             => "↪", # "\u21AA",
      :selected            => "•", # "\u2022",
      :unselected          => "○", # "\u25CB",
      :fallback_success    => "+",
      :fallback_error      => "!",
      :fallback_notice     => "!",
      :fallback_question   => "?",
      :fallback_general    => "-",
      :fallback_log        => "...",
      :fallback_restart    => "!",
      :fallback_selected   => "[x]",
      :fallback_unselected => "[ ]",
    }

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

    @state = nil
    @env = Env

    def speak(message, opts = {})
      format_message message, opts
      output_message
    end

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
          with(question) { |str| (" " * opt[:indent]) << str }
        end

        break
      end

      ask("#{question} :", *opts).gsub /\e\[\d+m/, ""
    end

    def agree?(question, opts = {})
      format_message question, {
        :color => opts.fetch("color", :blue),
        :icon  => :question
      }

      if opts[:simple]
        yes? " :", opts.fetch("color", {})
      else
        yes? "#{question} (y/N) :"
      end
    end

    def log(message)
      speak message, {
        :color => :yellow,
        :icon  => :log
      }
    end

    def success(message)
      speak message, {
        :color => [:black, :on_green, :bold],
        :icon  => :success,
        :row   => true
      }
    end

    def notice(message)
      speak message, {
        :color => [:black, :on_yellow],
        :icon  => :notice,
        :row   => true
      }
    end

    def error(message)
      speak message, {
        :color => [:white, :on_red],
        :icon  => :error,
        :row   => true
      }

      yield if block_given?

      exit 1
    end

    def hello(opts = {})
      speak "Welcome to Theme Juice!", {
        :color => [:black, :on_green, :bold],
        :row   => true
      }.merge(opts)
    end

    def goodbye(opts = {})

      # Have some fun?
      goodbyes = [
        "Bye, bye, bye",
        "Adios, muchachos",
        "See ya later, alligator",
        "Peace...",
        "Later, homes",
        "I'll be back",
        "Victory is ours!",
        "May the force be with you",
        "Take a break, man...",
        "It's not me, it's you",
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

    def open_project(url)
      speak "Do you want to open up your new project at 'http://#{url}' now? (y/N)", {
        :color => [:black, :on_blue],
        :icon  => :restart,
        :row   => true
      }

      if agree? "", { :simple => true }
        OS.open_file_command "http://#{url}"
      end
    end

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

    def choose(header, color, list)
      if OS.windows?
        ask header, {
          :limited_to => list,
          :color      => color
        }
      else
        speak "#{header} (use arrow keys and press enter)", {
          :color => :"#{color}",
          :icon  => :question
        }

        print "\n" * list.size

        selected = 0
        update_list_selection(list, color, selected)

        loop do
          key = read_key
          case key
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
    end

    private

    def update_list_selection(list, color, selected = 0)
      print "\e[#{list.size}A"

      list.each_with_index do |item, i|
        icon = i == selected ? "selected" : "unselected"
        speak "#{item}", {
          :color  => :"#{color}",
          :icon   => :"#{icon}",
          :indent => 2
        }
      end
    end

    #
    # @see http://www.alecjacobson.com/weblog/?p=75
    #
    def read_key
      save_stty_state
      raw_stty_mode

      key = STDIN.getc.chr

      if key == "\e"
        thread = Thread.new { key += STDIN.getc.chr + STDIN.getc.chr }
        thread.join(0.001)
        thread.kill
      end

      KEYS[key] || key
    ensure
      restore_stty_state
    end

    def save_stty_state
      @state = %x(stty -g)
    end

    def raw_stty_mode
      %x(stty raw -echo)
    end

    def restore_stty_state
      %x(stty #{@state})
    end

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

    def with(string)
      str = yield(string); string.clear; string << str
    end

    def format_message_icon
      icon = @env.no_unicode ? "fallback_#{@opts[:icon]}" : "#{@opts[:icon]}"

      if @opts[:icon]
        with(@message) { |msg| "#{ICONS[:"#{icon}"]}" << (@opts[:empty] ? nil : " #{msg}") }
      else
        with(@message) { |msg| "" << msg }
      end
    end

    def format_message_newline
      with(@message) { |msg| "\n" << msg } if @opts[:newline]
    end

    def format_message_color
      unless @env.no_colors
        with(@message) { |msg| set_color(msg, *@opts[:color]) } if @opts[:color]
      end
    end

    def format_message_row
      with(@message) { |msg| msg.ljust(terminal_width) } if @opts[:row]
    end

    def format_message_width
      with(@message) { |msg| msg.ljust(@opts[:width]) } if @opts[:width]
    end

    def format_message_indent
      with(@message) { |str| (" " * @opts[:indent]) << str } if @opts[:indent]
    end

    def output_message
      @opts[:quiet] ? @message : say(@message)
    end

    extend self
  end
end
