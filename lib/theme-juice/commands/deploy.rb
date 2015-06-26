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
              tasks << Tasks::Deploy::Stage.new
              tasks << Tasks::Deploy::VMStage.new
              tasks << Tasks::Deploy::Rsync.new
              tasks << Tasks::Deploy::Repo.new
            end

            self
          end
        end
      end
    end
  end
end
