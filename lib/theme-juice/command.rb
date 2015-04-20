# encoding: UTF-8

module ThemeJuice
  class Command < Task

    def initialize(opts = {})
      super
    end

    def execute
      @interact.log "Running method 'execute' for #{self.class.name}"
      @tasks.each { |task| task.execute }
    end

    def unexecute
      @interact.log "Running method 'unexecute' for #{self.class.name}"
      @tasks.reverse.each { |task| task.unexecute }
    end

    private

    def vm_location
      File.expand_path "#{@env.vm_path}/www/#{@env.vm_prefix}-#{@project.name}"
    end
  end
end
