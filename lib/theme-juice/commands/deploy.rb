# encoding: UTF-8

module ThemeJuice
  module Commands
    class Deploy < Command

      def initialize(opts = {})
        super

        @config.deployment.stages.keys.each do |stage|
          self.class.send :define_method, stage do |*args|
            @env.cap     = Capistrano::Application.new
            @env.stage   = stage.to_sym
            @env.archive = opts[:archive]

            runner do |tasks|
              tasks << Tasks::Settings.new
              tasks << Tasks::Stage.new
              tasks << Tasks::VMStage.new
              tasks << Tasks::Load.new
              tasks << Tasks::Invoke.new(args)
            end

            self
          end
        end
      end

      def method_missing(method, *args, &block)
        @io.error "It looks like the stage '#{method}' doesn't exist"
      end
    end
  end
end
