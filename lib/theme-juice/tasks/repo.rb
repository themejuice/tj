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
            cmds << "git init"
            cmds << "git remote add origin #{@project.repository}"
          end
        end
      end

      def remove_repo
        if @interact.agree "Do you want to overwrite the current repo in '#{@project.location}'?"
          @util.remove_dir git_dir, :verbose => @env.verbose
        else
          @interact.error "Run the command again without a repository, or remove the current repository"
        end
      end
    end
  end
end
