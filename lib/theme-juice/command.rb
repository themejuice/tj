# encoding: UTF-8

module ThemeJuice
  class Command < Task

    def initialize(opts = {})
      super

      @list = Tasks::List.new
    end

    def execute
      @tasks.each { |task| task.execute }
    end

    def unexecute
      @tasks.reverse.each { |task| task.unexecute }
    end
  end
end
