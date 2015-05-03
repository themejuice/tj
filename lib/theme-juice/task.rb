# encoding: UTF-8

module ThemeJuice
  class Task

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
      @io.error "Method 'execute' not implemented for #{self.class.name}"
    end

    def unexecute
      @io.error "Method 'unexecute' not implemented for #{self.class.name}"
    end

    private

    def vm_root
      File.expand_path "#{@env.vm_path}/www"
    end

    def vm_location
      "#{vm_root}/#{@env.vm_prefix}#{@project.name}"
    end

    def vm_srv_location
      "/srv/www/#{@env.vm_prefix}#{@project.name}"
    end
  end
end
