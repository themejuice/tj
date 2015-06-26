# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super

        @config.deployment.stages.keys.each do |stage|
          self.class.send :define_method, stage do |*args|
            @env.cap = {
              :config => Capistrano::Configuration.new,
              :app    => Capistrano::Application.new,
              :stage  => stage
            }

            runner do |tasks|
              tasks << Tasks::Stage.new
              tasks << Tasks::VMStage.new
              tasks << Tasks::Rsync.new
              tasks << Tasks::SCM.new
            end

            self
          end
        end
      end
    end
  end
end
