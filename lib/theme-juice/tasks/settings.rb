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

          set :linked_files, fetch(:linked_files, []).push(fetch(:shared_files))
          set :linked_dirs, fetch(:linked_dirs, []).push(fetch(:uploads_dir))

          # Required global settings
          %w[settings repository].each do |task|
            @config.deployment.send(task).symbolize_keys.each do |key, value|
              set key, proc { value }
            end
          end

          # Optional namespaced settings
          %w[rsync slack].each do |task|
            if @config.deployment.key? task
              @config.deployment.send(task).symbolize_keys.each do |key, value|
                set :"#{task}_#{key}", proc { value }
              end
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
