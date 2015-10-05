# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Repo < Task

      def initialize(opts = {})
        super
      end

      def execute
        return unless @project.repository

        create_repo
      end

      private

      def git_dir
        File.expand_path "#{@project.location}/.git"
      end

      def repo_is_setup?
        File.exist? git_dir
      end

      def create_repo
        @io.log "Creating Git repository"

        remove_repo if repo_is_setup?

        @util.inside @project.location do
          @util.run [], { :verbose => @env.verbose,
            :capture => @env.quiet } do |cmds|
            cmds << "git init"
            cmds << "git remote add origin #{@project.repository}"
          end
        end
      end

      def remove_repo
        if @io.agree? "Do you want to overwrite the current repo in '#{@project.location}'?"
          @util.remove_dir git_dir, { :verbose => @env.verbose,
            :capture => @env.quiet }
        else
          @io.error "Run the command again without a repository, or remove the repository currently in '#{@project.location}'"
        end
      end
    end
  end
end
