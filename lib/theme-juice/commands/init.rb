# encoding: UTF-8

module ThemeJuice
  module Commands
    class Init < Command

      def initialize(opts = {})
        super

        init_project

        runner do |tasks|
          tasks << Tasks::InitConfirm.new
          tasks << Tasks::VMBox.new
          tasks << Tasks::VMPlugins.new
          tasks << Tasks::VMCustomfile.new
          tasks << Tasks::Landrush.new
          tasks << Tasks::ForwardPorts.new
          tasks << Tasks::VMProvision.new if @project.vm_provision
          tasks << Tasks::InitSuccess.new
        end
      end

      def init_project
        @project.vm_provision = @opts.fetch("vm_provision") { false }
      end
    end
  end
end
