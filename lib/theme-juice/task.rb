# encoding: UTF-8

module ThemeJuice
  class Task

    def initialize(opts = {})
      @env      = Env
      @interact = Interact
      @project  = Project
      @io       = IO
      @opts     = opts.dup
      @tasks    = []
    end

    def runner
      yield @tasks
    end

    def do
      @interact.error "Method 'do' not implemented for #{self.class.name}"
    end

    def undo
      @interact.error "Method 'undo' not implemented for #{self.class.name}"
    end
  end
end
