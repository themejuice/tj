# encoding: UTF-8

module ThemeJuice
  class Command < Task

    def initialize(opts = {})
      super
    end

    def execute
      @interaction.error "Execute method not implemented ... exiting"
    end
  end
end
