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
              :stage  => stage.to_sym,
              :args   => args
            }

            runner do |tasks|
              tasks << Tasks::Deploy::App.new
              tasks << Tasks::Deploy::Stage.new
              tasks << Tasks::Deploy::VMStage.new
              tasks << Tasks::Deploy::Rsync.new
              tasks << Tasks::Deploy::Repo.new
              tasks << Tasks::Deploy::Settings.new
              tasks << Tasks::Deploy::LoadCapistrano.new
              tasks << Tasks::Deploy::Invoke.new
            end

            self
          end
        end
      end

      def method_missing(method)
        @io.error "It looks like the stage '#{method}' doesn't exist"
      end
    end
  end
end
