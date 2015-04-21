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

          handle_multi_command command, config
        else
          handle_single_command command, config
        end
      end

      private

      def handle_multi_command(commands, config)
        commands = commands.join "&&"

        if @env.dryrun
          _run "echo #{escape_command(commands)}", config
        else
          _run commands, config
        end
      end

      def handle_single_command(command, config)
        if @env.dryrun
          _run "echo #{escape_command(command)}", config
        else
          _run command, config
        end
      end

      def escape_command(command)
        Shellwords.escape(command)
      end
    end
  end
end
