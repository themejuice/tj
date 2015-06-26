# encoding: UTF-8

module ThemeJuice
  class Subcommand
    def initialize(opts = {})
      @env     = Env
      @io      = IO
      @project = Project
      @config  = Config
      @util    = Util.new
      @opts    = opts.dup
    end
  end
end
