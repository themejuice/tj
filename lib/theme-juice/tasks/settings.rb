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
        configure_shared
        configure_rsync
        configure_slack if @config.deployment[:slack]
      end

      private

      def configure_settings
        @io.log "Configuring Capistrano"

        begin
          set :application, @config.deployment.application.name

          %w[settings repository].each do |task|
            @config.deployment.send(task).symbolize_keys.each do |key, value|
              set key, proc { value }
            end
          end
        rescue NoMethodError => err
          @io.error "Oops! It looks like you're missing a few deployment settings" do
            puts err
          end
        end
      end

      def configure_shared
        set :linked_files, fetch(:linked_files, []).push(fetch(:shared_files))
        set :linked_dirs, fetch(:linked_dirs, []).push(fetch(:uploads_dir))
      end

      def configure_rsync
        @config.deployment.rsync.symbolize_keys.each do |key, value|
          set :"rsync_#{key}", proc { value }
        end
      end

      def configure_slack
        @config.deployment.slack.symbolize_keys.each do |key, value|
          set :"slack_#{key}", proc { value }
        end

        set :slack_deploy_starting_text, -> do
          "We have lift off! Deploying *#{fetch(:application)}* to \
          #{fetch(:stage)}. :satellite:"
        end

        set :slack_deploy_failed_text, -> do
          "Houston, we have a problem! Deployment of *#{fetch(:application)}* \
           to #{fetch(:stage)} has failed! #{fetch(:slack_deployer).capitalize}, \
           you better check your terminal output. :earth_americas: \
           :ambulance: :ambulance:"
        end

        set :slack_text, -> do
          "Mission complete! Deployment of *#{fetch(:application)}* to \
           #{fetch(:stage)} was successful _and it only took a measly \
           #{fetch(:time_finished).to_i - fetch(:time_started).to_i} seconds!_"
        end
      end
    end
  end
end
