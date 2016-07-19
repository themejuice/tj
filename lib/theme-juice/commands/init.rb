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
          tasks << Tasks::VMProvision.new
          tasks << Tasks::InitSuccess.new
        end
      end

      def init_project
        @project.provision = @opts.fetch("provision") { false }
      end
    end
  end
end
