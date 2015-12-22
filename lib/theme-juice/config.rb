# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new
    @config  = nil

    def command(cmd, *args)
      commands.fetch("#{cmd}") {
        @io.error "Command '#{cmd}' not found in config", NotImplementedError }
        .each { |c| run format_command(c, *args) }
    rescue NoMethodError
      @io.say "Skipping...", :color => :yellow, :icon => :notice
    end

    def commands
      config.commands
    rescue NoMethodError
      {}
    end

    def deployment
      config.deployment
    rescue NoMethodError
      @io.error("Deployment settings not found in config", NotImplementedError)
    end

    def exist?
      !capture { config }.nil?
    end

    private

    def run(command)
      @util.inside @project.location do
        @util.run command, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end

    def format_command(cmd, args = [])
      if multi_arg_regex =~ cmd
        cmd.gsub! multi_arg_regex, args.join(" ")
      else
        args.to_enum.with_index(1).each do |arg, i|
          cmd.gsub! single_arg_regex(i), arg
        end
      end
      cmd
    end

    def config
      @config = read_config if @config.nil?
      @config
    end

    def read_config
      @project.location ||= Dir.pwd

      YAML.load_file Dir["#{@project.location}/*"].select { |f|
        config_regex =~ File.basename(f) }.last ||
        @io.error("Config file not found in '#{@project.location}'", LoadError)
    rescue ::Psych::SyntaxError => err
      @io.error "Config file contains invalid YAML", SyntaxError do
        puts err
      end
    rescue LoadError, SystemExit
      nil
    end

    def config_regex
      %r{^(((\.)?(tj)|((J|j)uicefile))(\.y(a)?ml)?$)}
    end

    def multi_arg_regex
      %r{(%args%)|(%arguments%)}
    end

    def single_arg_regex(i)
      %r{(%arg#{i}%)|(%argument#{i}%)}
    end

    def capture
      begin
        old = $stdout
        $stdout = StringIO.new
        yield
        # $stdout.string
      ensure
        $stdout = old
      end
    end

    extend self
  end
end
