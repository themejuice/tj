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

    @env = Env
    @sel = 0

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
      speak "#{header} (#{choose_instructions})", {
        :color => :"#{color}",
        :icon  => :question
      }

      list.each { puts }
      update_selection list, color

      loop do
        key = read_key
        case key
        when "up", "w"
          update_selection list, color, -1
        when "down", "s"
          update_selection list, color, 1
        when "return", "linefeed", "space"
          return list[@sel]
        when "esc", "ctrl+c"
          goodbye :newline => false
        else
          speak key.inspect, { :color => :yellow }
        end
      end
    end

    private

    def choose_instructions
      if OS.windows?
        "use WASD keys and press space"
      else
        "use arrow keys and press enter"
      end
    end

    def update_selection(list, color, diff = 0)
      list.each { print "\e[1A" }

      @sel += diff
      @sel = 0 if @sel > list.size - 1
      @sel = list.size - 1 if @sel < 0

      list.each_with_index do |item, i|
        icon = i == @sel ? "selected" : "unselected"
        speak "#{item}", {
          :color  => :"#{color}",
          :icon   => :"#{icon}",
          :indent => 2
        }
      end
    end

    def read_key
      STDIN.noecho do
        STDIN.raw!

        key = STDIN.getc.chr

        if key == "\e"
          key << STDIN.getc.chr rescue nil
          key << STDIN.getc.chr rescue nil
        end

        STDIN.cooked!

        KEYS[key] || key
      end
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
      unless OS.windows?
        with(@message) { |msg| msg.ljust(terminal_width) } if @opts[:row]
      end
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
