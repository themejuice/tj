# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new

    def method_missing(method, *args, &block)
      @project.location ||= Dir.pwd

      begin
        self.send method, args.shift, *args
      rescue
        @io.error "Unknown method '#{type}' passed to config"
      end
    end

    private

    def command(cmd, *args)
      begin
        config.fetch("commands", {})
          .fetch("#{cmd}") { @io.error "Command '#{cmd}' not found in config", NotImplementedError }
          .each { |c| run format_command(c, *args) }
      rescue NoMethodError
        @io.say "Skipping...", :color => :yellow, :icon => :notice
      end
    end

    def deployment(key, *args)
      config.fetch("deployment") { @io.error "Deployment settings not found in config", NotImplementedError }
        .fetch("#{key}") { @io.error "Deployment option '#{key}' not found in config", NotImplementedError }
    end

    def run(command)
      @util.inside @project.location do
        @util.run command, :verbose => @env.verbose
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
      begin
        YAML.load_file Dir["#{@project.location}/*"].select { |f| config_regex =~ File.basename(f) }.last ||
          @io.error("Config file not found in '#{@project.location}'", LoadError)
      rescue ::Psych::SyntaxError => err
        @io.error "Config file contains invalid YAML", SyntaxError do
          puts err
        end
      rescue LoadError, SystemExit
        nil
      end
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

    extend self
  end
end
