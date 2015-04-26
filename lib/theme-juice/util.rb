# encoding: UTF-8

module ThemeJuice
  class Util < Thor
    include Thor::Actions

    def initialize(args = [], options = {}, config = {})
      @env      = Env
      @interact = Interact
      @project  = Project

      options.merge! :pretend => @env.dryrun

      super args, options, config
    end

    #
    # Monkey patch some of Thor's default actions to add a little
    #  extra functionality
    #
    no_commands do

      alias_method :_run, :run

      def run(command, config = {}, &block)
        if command.is_a? Array
          yield command if block_given?
          run_multi_command command, config
        else
          run_single_command command, config
        end
      end

      private

      def run_multi_command(commands, config)
        commands = commands.join "&&"
        _run commands, config
      end

      def run_single_command(command, config)
        _run command, config
      end
    end
  end
end
