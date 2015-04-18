# encoding: UTF-8

module ThemeJuice
  class Command < Task

    def initialize(opts = {})
      super
    end

    def do
      @interact.log "Running method 'do' for #{self.class.name}"
      @tasks.each { |task| task.do }
    end

    def undo
      @interact.log "Running method 'undo' for #{self.class.name}"
      @tasks.each { |task| task.undo }
    end

    private

    def vm_location
      File.expand_path "#{@env.vvv_path}/www/#{@env.vm_prefix}-#{@project.name}"
    end

    #
    # Run system commands
    #
    # @param {Array} commands
    #   Array of commands to run
    # @param {Bool}  silent   (true)
    #   Silence all output from command
    #
    # @return {Void}
    #
    def run(commands, silent = true)
      commands.map! { |cmd| "#{cmd.to_s} > /dev/null 2>&1" } if silent
      system commands.join "&&"
    end
  end
end
