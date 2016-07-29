# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new
    @config  = nil

    attr_accessor :path

    def command(cmd, *args)
      return if @project.no_config

      args.map { |arg|
        arg.reject! { |a| /^-/ =~ a } if arg.is_a?(Array) }

      commands.fetch("#{cmd}") {
        @io.error "Command '#{cmd}' not found in config", NotImplementedError }
        .each { |c| cmds = format_command(c, *args)
          @env.inside_vm ? run_inside_vm(cmds) : run(cmds) }
    rescue NoMethodError
      @io.say "Skipping...", :color => :yellow, :icon => :notice
    end

    def project
      config.project
    rescue NoMethodError
      {}
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

    def refresh!
      @config = read
    end

    private

    def run(command)
      @util.inside (@env.from_path || @project.location) do
        @util.run command, { :verbose => @env.verbose,
          :capture => @env.quiet }
      end
    end

    def run_inside_vm(command)
      project_dir = @env.from_srv || @project.vm_srv

      @util.inside @env.vm_path do
        @util.run "vagrant ssh -c 'cd #{project_dir} && #{command}'", {
          :verbose => @env.verbose, :capture => @env.quiet }
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
      cmd.gsub! any_arg_regex, ""
      cmd
    end

    def config
      @config ||= read
    end

    def read
      @project.location ||= @env.from_path || Dir.pwd
      @project.name ||= File.basename @project.location

      @path = Dir["#{@project.location}/*"].select { |f|
        config_regex =~ File.basename(f)
      }.last || @io.error("Config file not found in '#{@project.location}'", LoadError)

      YAML.load File.read(@path)
    rescue ::Psych::SyntaxError => err
      @io.error "Config file contains invalid YAML", SyntaxError do
        puts err
      end
    rescue LoadError, SystemExit
      nil
    end

    # Allowed:
    # - Juicefile
    # - Juicefile.yml
    # - Juicefile.yaml
    # - juicefile
    # - juicefile.yml
    # - juicefile.yaml
    # - .tj
    # - .tj.yml
    # - .tj.yaml
    def config_regex
      %r{^(\.?(tj)|((J|j)uicefile))(\.ya?ml)?$}
    end

    def any_arg_regex
      %r{%arg(?:ument)?[s\d]+%}
    end

    def multi_arg_regex
      %r{%arg(?:ument)?s%}
    end

    def single_arg_regex(i)
      %r{%arg(?:ument)?#{i}%}
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
