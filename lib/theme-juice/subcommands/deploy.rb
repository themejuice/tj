# encoding: UTF-8

module ThemeJuice
  module Subcommands
    class Deploy < Subcommand

      def initialize(opts = {})
        super
      end

      Config.deployment.stages.keys.each do |stage|
        define_method "#{stage}" do
          @io.log "Deploying to #{stage}"
        end
      end
    end
  end
end
