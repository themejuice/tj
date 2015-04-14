# encoding: UTF-8

module ThemeJuice
  class Task
    include ::Thor::Actions
    include ::Thor::Shell

    def initialize(opts = {})
      @env      = Env
      @interact = Interact
      @project  = Project
      @opts     = opts.dup
      @tasks    = []
    end

    def runner
      yield @tasks
    end

    def do
      @interact.error "Method 'do' not implemented for #{self}"
    end

    def undo
      @interact.error "Method 'undo' not implemented for #{self}"
    end
  end
end
