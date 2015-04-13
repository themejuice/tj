# encoding: UTF-8

module ThemeJuice
  class Task
    include ::Thor::Actions
    include ::Thor::Shell

    def initialize(opts = {})
      @environment = ::ThemeJuice::Environment
      @interaction = ::ThemeJuice::Interaction
      @opts        = opts
      @tasks       = []

      yield @tasks if block_given?

      @tasks
    end
  end
end
