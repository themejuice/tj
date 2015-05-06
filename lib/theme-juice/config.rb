# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new

    def method_missing(method, *args, &block)
      @project.location ||= Dir.pwd

      puts method, *args

      config.fetch("commands", {})
        .fetch(method.to_s) { @io.error("Command '#{method}' not found in config") }
        .each { |cmd| run format_command(cmd, *args) }
    end

    private

    def run(command)
      @util.inside @project.location do
        @util.run command, :verbose => @env.verbose
      end
    end

    def format_command(cmd, args)

      if %r{(%args%)|(%arguments%)} =~ cmd
        cmd.gsub! %r{(%args%)|(%arguments%)}, args.join(" ")
      else
        args.to_enum.with_index(1).each do |arg, i|
          cmd.gsub! %r{(%arg#{i}%)|(%argument#{i}%)}, arg
        end
      end

      cmd
    end

    def config
      begin
        YAML.load_file Dir["#{@project.location}/*"].select { |f| regex =~ File.basename(f) }.last ||
          @io.error("Config file not found in '#{@project.location}'")
      rescue ::Psych::SyntaxError => err
        @io.error "Config file is invalid" do
          puts err
        end
      end
    end

    def regex
      %r{^(((\.)?(tj)|((J|j)uicefile))(.y(a)?ml)?$)}
    end

    extend self
  end
end
