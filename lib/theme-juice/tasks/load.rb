# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Load < Task

      def initialize
        super
      end

      def execute
        load_capistrano
        load_tasks
        load_custom_tasks
      end

      private

      def load_capistrano
        @io.log "Loading Capistrano"

        require "capistrano/setup"
        require "capistrano/deploy"
        require "capistrano/rsync"
        require "capistrano/slackify" if @config.deployment.key? "slack"
        require "capistrano/framework"
      end

      def load_tasks
        @io.log "Loading Capistrano tasks"

        tasks_dir = "#{File.dirname(__FILE__)}/capistrano"
        tasks     = %w[db uploads file dir env rsync]

        tasks.each { |task| load "#{tasks_dir}/#{task}.rb" }
      end

      def load_custom_tasks
        @io.log "Loading custom Capistrano tasks"

        tasks_dir = "#{@project.location}/deploy"

        Dir.glob("#{tasks_dir}/*.{rb,cap,rake}").each { |task| load task }
      end
    end
  end
end
