# encoding: UTF-8

module ThemeJuice
  class Util < Thor
    include Thor::Actions

    def initialize(*)
      super

      @env      = Env
      @interact = Interact
      @project  = Project
    end

    def self.destination_root
      @project.location
    end

    no_commands do

      alias_method :_run, :run

      def run(command, config = {}, &block)

        if command.is_a? Array
          yield command if block_given?

          if @env.dryrun
            _run "echo #{escape_command(command.join("&&"))}", config
          else
            _run command.join("&&"), config
          end
        else
          if @env.dryrun
            _run "echo #{escape_command(command)}", config
          else
            _run command, config
          end
        end
      end

      def escape_command(command)
        Shellwords.escape(command)
      end
    end
  end
end
