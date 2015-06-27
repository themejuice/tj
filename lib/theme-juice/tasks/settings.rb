# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Settings < Task
      include Capistrano::DSL

      def initialize
        super
      end

      def execute
        configure_settings
      end

      private

      def configure_settings
        @io.log "Configuring Capistrano"

        begin
          set :application, @config.deployment.application.name
          set :rsync_options, @config.deployment.rsync_options
          %w[settings repository].each do |task|
            @config.deployment.send(task).symbolize_keys.each do |key, value|
              set key, value
            end
          end
        rescue NoMethodError => err
          @io.error "Oops! It looks like you're missing a few deployment settings" do
            puts err
          end
        end
      end
    end
  end
end
