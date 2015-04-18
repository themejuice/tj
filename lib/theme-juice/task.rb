# encoding: UTF-8

module ThemeJuice
  class Task

    def initialize(opts = {})
      @env      = Env
      @interact = Interact
      @project  = Project
      @util     = Util.new
      @opts     = opts.dup
      @tasks    = []
    end

    def runner
      yield @tasks
    end

    def execute
      @interact.error "Method 'execute' not implemented for #{self.class.name}"
    end

    def unexecute
      @interact.error "Method 'unexecute' not implemented for #{self.class.name}"
    end
  end
end
