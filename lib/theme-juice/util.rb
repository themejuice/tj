# encoding: UTF-8

module ThemeJuice
  class Util < Thor
    include Thor::Actions

    def initialize(args = [], options = {}, config = {})
      @env      = Env
      @io       = IO
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
          _run command.join("&&"), config
        else
          _run command, config
        end
      end

      def run_inside_vm(command, config = {}, &block)
        inside @env.vm_path do
          if command.is_a? Array
            yield command if block_given?
            _run %Q[vagrant ssh -c "#{command.join("&&")}"], config
          else
            _run %Q[vagrant ssh -c "#{command}"], config
          end
        end
      end
    end
  end
end
