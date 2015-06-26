# encoding: UTF-8

module ThemeJuice
  module Subcommands
    class Deploy < Subcommand
      extend ::Capistrano::DSL

      def initialize(opts = {})
        super

        @settings   = @config.deployment
        @capistrano = {
          :config => Capistrano::Configuration.new,
          :app => Capistrano::Application.new
        }

        init_stages
      end

      private

      def init_stages
        @settings.stages.keys.each do |stage|
          self.class.send :define_method, stage do |*args|
            @io.log "Deploying to #{stage} with args: #{args}"
          end
        end
      end
    end
  end
end
