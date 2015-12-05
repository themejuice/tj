# encoding: UTF-8

module ThemeJuice
  class Task
    attr_reader :tasks

    def initialize(opts = {})
      @env     = Env
      @io      = IO
      @project = Project
      @config  = Config
      @util    = Util.new
      @opts    = opts.dup
      @tasks   = []
    end

    def runner
      yield @tasks
    end

    def execute
      @io.error "Method 'execute' not implemented for #{self.class.name}", NotImplementedError
    end

    def unexecute
      @io.error "Method 'unexecute' not implemented for #{self.class.name}", NotImplementedError
    end
  end
end
