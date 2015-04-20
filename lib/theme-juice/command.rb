# encoding: UTF-8

module ThemeJuice
  class Command < Task

    def initialize(opts = {})
      super
    end

    def execute
      @tasks.each { |task| task.execute }
    end

    def unexecute
      @tasks.reverse.each { |task| task.unexecute }
    end

    private

    def vm_location
      File.expand_path "#{@env.vm_path}/www/#{@env.vm_prefix}-#{@project.name}"
    end
  end
end
