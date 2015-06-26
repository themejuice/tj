# encoding: UTF-8

module ThemeJuice
  module Subcommands
    class Deploy < Subcommand

      def initialize(opts = {})
        super

        @settings = @config.deployment

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
