# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Settings < Task
      include Capistrano::DSL

      def initialize
        super
      end

      def execute
        @io.log "Configuring Capistrano"

        # We define this as a Rake task so our settings don't get overridden
        #  when invoking the 'load:defaults' task before deployment
        ::Rake::Task.define_task "load:settings" do
          configure_required_settings
          configure_optional_settings
        end
      end

      private

      # Required global settings
      def configure_required_settings
        if @config.deployment.application.name
          @io.notice "Deprecation Notice: 'config.deployment.application.name' has been deprecated! Please use 'config.project.name' instead."
          set :application, @config.deployment.application.name
        else
          set :application, @config.project.name
        end
        set :archive,      @env.archive

        set :linked_files, fetch(:linked_files, []).concat(fetch(:shared_files, []))
        set :linked_dirs,  fetch(:linked_dirs, []).concat(fetch(:shared_dirs, []))
           .push(fetch(:uploads_dir, ""))

        %w[settings repository].each do |task|
          @config.deployment.send(task).symbolize_keys.each do |key, value|
            set key, proc { value }
          end
        end

        # Allow the branch to be overridden (casts possible nil to string)
        unless @env.branch.to_s.empty?
          set :branch, @env.branch
        end
      rescue NoMethodError => err
        @io.error "Oops! It looks like you're missing a few deployment settings" do
          puts err
        end
      end

      # Optional namespaced settings
      def configure_optional_settings
        %w[rsync slack].each do |task|
          next unless @config.deployment.key? task

          @config.deployment.send(task).each do |key, value|
            set :"#{task}_#{key}", proc { value }
          end
        end
      end
    end
  end
end
