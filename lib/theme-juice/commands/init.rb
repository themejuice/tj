# encoding: UTF-8

module ThemeJuice
  module Commands
    class Init < Command

      def initialize(opts = {})
        super

        runner do |tasks|
          tasks << Tasks::InitConfirm.new
          tasks << Tasks::VMBox.new
          tasks << Tasks::VMPlugins.new
          tasks << Tasks::VMLocation.new
          tasks << Tasks::VMCustomfile.new
          tasks << Tasks::Landrush.new
          tasks << Tasks::ForwardPorts.new
          tasks << Tasks::VMProvision.new
          tasks << Tasks::InitSuccess.new
        end
      end
    end
  end
end
