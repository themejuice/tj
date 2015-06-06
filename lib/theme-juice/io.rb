# encoding: UTF-8

module ThemeJuice
  module IO
    include Thor::Shell
    
    alias_method :_say, :say
    alias_method :_ask, :ask

    ICONS = {
      :success             => "✓",
      :error               => "↑",
      :notice              => "→",
      :question            => "•",
      :general             => "›",
      :log                 => "…",
      :restart             => "↪",
      :selected            => "•",
      :unselected          => "○",
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
      "w"    => "w",
      "s"    => "s",
      "\003" => "ctrl+c",
      "\004" => "ctrl+d",
      "\e"   => "escape",
      "\n"   => "linefeed",
      "\r"   => "return",
      " "    => "space",
    }

    @env     = Env
    @project = Project
    @sel     = 0

    def say(message, opts = {})
      output_message format_message(message, opts), opts
    end

    def ask(question, *opts)
      indentation = if opts[0].respond_to? :fetch
                      opts[0].fetch :indent, 0
                    else
                      0
                    end
      
      q = format_message question, {
        :color  => :blue,
        :icon   => :question,
        :indent => indentation
      }

      _ask("#{q} :", *opts).gsub /\e\[\d+m/, ""
    end

    def agree?(question, opts = {})
      q = format_message question, {
        :color => opts.fetch("color", :blue),
        :icon  => :question
      }

      yes? "#{q} (y/N) :"
    end

    def log(message)
      say message, {
        :color => :yellow,
        :icon  => :log
      }
    end

    def success(message)
      say message, {
        :color => [:black, :on_green, :bold],
        :icon  => :success,
        :row   => true
      }
    end

    def notice(message)
      say message, {
        :color => [:black, :on_yellow],
        :icon  => :notice,
        :row   => true
      }
    end

    def error(message, code = SystemExit)
      say message, {
        :color => [:white, :on_red],
        :icon  => :error,
        :row   => true
      }

      yield if block_given?

      raise code
    end

    def hello(opts = {})
      say "Welcome to Theme Juice!", {
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
      
      say goodbyes.sample, {
        :color   => :yellow,
        :newline => true
      }.merge(opts)

      exit 1
    end

    def list(header, color, list)
      say header, {
        :color => [:black, :"on_#{color}"],
        :icon  => :notice,
        :row   => true
      }

      list.each do |item|
        say item, {
          :color => :"#{color}",
          :icon  => :general
        }
      end
    end

    def choose(header, color, list)
      say "#{header} (#{choose_instructions})", {
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
        # else
        #   say key.inspect, { :color => :yellow }
        end
      end
    end

    private
    
    # @todo Windows has issues registering the arrow and enter keys
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
        say "#{item}", {
          :color  => :"#{color}",
          :icon   => :"#{icon}",
          :indent => 2
        }
      end
    end

    def read_key
      $stdin.noecho do |io|
        io.raw!

        key = io.getc.chr

        if key == "\e"
          key << io.getc.chr rescue nil
          key << io.getc.chr rescue nil
        end

        io.cooked!

        KEYS[key] || key
      end
    end

    def format_message(message, opts = {})
      
      %W[icon newline row width color indent].each do |f|
        message = self.send("format_#{f}", message, opts)
      end
      
      message
    end

    def format_icon(message, opts)
      return message if opts[:icon].nil?

      icon = if @env.no_unicode
               "fallback_#{opts[:icon]}"
             else
               "#{opts[:icon]}"
             end
             
      "#{ICONS[:"#{icon}"]} " << message
    end

    def format_newline(message, opts)
      return message if opts[:newline].nil?
      
      "\n" << message
    end

    def format_color(message, opts)
      return message if @env.no_colors || opts[:color].nil?
      
      set_color(message, *opts[:color])
    end

    def format_row(message, opts)
      return message if OS.windows? || opts[:row].nil?
      
      message.ljust terminal_width
    end

    def format_width(message, opts)
      return message if opts[:width].nil?
      
      message.ljust opts[:width]
    end

    def format_indent(message, opts)
      return message if opts[:indent].nil?
      
      (" " * opts[:indent]) << message
    end

    def output_message(message, opts)
      if opts[:quiet]
        message
      else
        _say message
      end
    end

    extend self
  end
end
