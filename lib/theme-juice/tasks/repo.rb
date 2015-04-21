# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Repo < Task

      def initialize(opts = {})
        super
      end

      def execute
        if @project.repository
          create_repo
        end
      end

      private

      def git_dir
        File.expand_path "#{@project.location}/.git"
      end

      def repo_is_setup?
        File.exist? git_dir
      end

      def create_repo
        @interact.log "Creating Git repository"

        remove_repo if repo_is_setup?

        @util.inside @project.location do
          @util.run [], :verbose => @env.verbose do |cmds|
            cmds << "git init",
            cmds << "git remote add origin #{@project.repository}",
          end
        end
      end

      def remove_repo
        @util.remove_dir git_dir, :verbose => @env.verbose
      end
    end
  end
end
