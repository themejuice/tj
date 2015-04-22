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
      alias_method :_create_file, :create_file
      alias_method :_append_to_file, :append_to_file

      def run(command, config = {}, &block)

        if command.is_a? Array
          yield command if block_given?

          run_multi_command command, config
        else
          run_single_command command, config
        end
      end

      def create_file(destination, *args, &block)
        if @env.dryrun
          data = block_given? ? block : args.shift
          _run %Q{echo #{escape("#{destination}: (write)\n#{data.call}")}}, *args
        else
          _create_file destination, *args, &block
        end
      end

      def append_to_file(path, *args, &block)
        if @env.dryrun
          data = block_given? ? block : args.shift
          _run %Q{echo #{escape("#{path}: (append)\n#{data.call}")}}, *args
        else
          _append_to_file path, *args, &block
        end
      end

      private

      def run_multi_command(commands, config)
        commands = commands.join "&&"

        if @env.dryrun
          _run %Q{echo #{escape(commands)}}, config
        else
          _run commands, config
        end
      end

      def run_single_command(command, config)
        if @env.dryrun
          _run %Q{echo #{escape(command)}}, config
        else
          _run command, config
        end
      end

      def escape(command)
        Shellwords.escape(command)
      end
    end
  end
end
