# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Settings < Task
      include Capistrano::DSL

      def initialize
        super

        @settings = @config.deployment
      end

      def execute
        configure_settings
      end

      private

      def configure_settings
        @io.log "Configuring Capistrano"

        set :application, @settings.application.name
        set :rsync_options, @settings.rsync_options rescue nil
        %w[settings repository].each do |task|
          @settings.send(task).symbolize_keys.each do |key, value|
            set key, value
          end
        end
      end
    end
  end
end
