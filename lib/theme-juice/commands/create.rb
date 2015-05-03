# encoding: UTF-8

module ThemeJuice
  module Commands
    class Create < Command

      def initialize(opts = {})
        super

        @project.use_defaults = @opts.fetch("use_defaults", false)
        @project.bare         = @opts.fetch("bare", false)
        @project.skip_repo    = @opts.fetch("skip_repo", false)
        @project.skip_db      = @opts.fetch("skip_db", false)
        @project.no_wp        = @opts.fetch("no_wp", false)
        @project.no_db        = @opts.fetch("no_db", false)
        @project.name         = @opts.fetch("name") { name }
        @project.location     = @opts.fetch("location") { location }
        @project.url          = @opts.fetch("url") { url }
        @project.theme        = @opts.fetch("theme") { theme }
        @project.repository   = @opts.fetch("repository") { repository }
        @project.db_host      = @opts.fetch("db_host") { db_host }
        @project.db_name      = @opts.fetch("db_name") { db_name }
        @project.db_user      = @opts.fetch("db_user") { db_user }
        @project.db_pass      = @opts.fetch("db_pass") { db_pass }
        @project.db_import    = @opts.fetch("db_import") { db_import }
        @project.vm_root      = vm_root
        @project.vm_location  = vm_location
        @project.vm_srv       = vm_srv

        runner do |tasks|
          tasks << Tasks::CreateConfirm.new
          tasks << Tasks::Location.new
          tasks << Tasks::Theme.new
          tasks << Tasks::VM.new
          tasks << Tasks::VMPlugins.new
          tasks << Tasks::VMLocation.new
          tasks << Tasks::VMCustomfile.new
          tasks << Tasks::Hosts.new
          tasks << Tasks::Database.new
          tasks << Tasks::Nginx.new
          tasks << Tasks::DotEnv.new
          tasks << Tasks::Landrush.new
          tasks << Tasks::SyncedFolder.new
          tasks << Tasks::DNS.new
          tasks << Tasks::WPCLI.new
          tasks << Tasks::Repo.new
          tasks << Tasks::CreateSuccess.new
          tasks << Tasks::ImportDatabase.new
        end
      end

      private

      def name
        if @env.yolo
          name = Faker::Internet.domain_word
        else
          name = @io.prompt "What's the project name? (letters, numbers and dashes only)"
        end

        valid_name? name

        name
      end

      def valid_name?(name)
        if name.empty?
          @io.error "Project name '#{name}' looks like it's empty. Aborting mission."
        end

        "#{name}".match /[^0-9A-Za-z.\-]/ do |char|
          @io.error "Project name contains an invalid character '#{char}'. This name is used internally for a ton of stuff, so that's not gonna work. Aborting mission."
        end

        true
      end

      def clean_name
        "#{@project.name}".gsub(/[^\w]/, "_")[0..10]
      end

      def location
        path = "#{Dir.pwd}/"

        if @project.use_defaults
          location = File.expand_path path
        else
          location = File.expand_path @io.prompt("Where do you want to setup the project?", :default => path, :path => true)
        end

        location
      end

      def url
        if @project.use_defaults
          url = "#{@project.name}.dev"
        else
          url = @io.prompt "What do you want the development url to be? (this should end in '.dev')", :default => "#{@project.name}.dev"
        end

        valid_url? url

        url
      end

      def valid_url?(url)
        unless "#{url}".match /(.dev)$/
          @io.error "Your development url '#{url}' doesn't end with '.dev'. This is used internally by Landrush, so that's not gonna work. Aborting mission."
        end

        true
      end

      def theme
        return false if @project.bare

        theme = nil
        themes = {
          "theme-juice/theme-juice-starter" => "https://github.com/ezekg/theme-juice-starter.git",
          "other"                           => nil,
          "none"                            => nil
        }

        if @project.use_defaults
          theme = themes["theme-juice/theme-juice-starter"]
        else
          choice = @io.choose "Which starter theme would you like to use?", :blue, themes.keys

          case choice
          when "theme-juice/theme-juice-starter"
            @io.success "Awesome choice!"
          when "other"
            themes[choice] = @io.prompt "What is the repository URL for the starter theme that you would like to clone?"
          when "none"
            @io.notice "Next time you need to create a project without a starter theme, you can just run the 'setup' command instead."
            @project.bare = true
          end

          theme = themes[choice]
        end

        theme
      end

      def repository
        return false if @project.skip_repo || @project.use_defaults

        if @io.agree? "Would you like to initialize a new Git repository?"
          repo = @io.prompt "What is the repository's remote URL?", :indent => 2
        else
          repo = false
        end

        repo
      end

      def db_host
        return false if @project.no_db || @project.no_wp

        if @project.skip_db || @project.use_defaults
          db_host = "vvv"
        else
          db_host = @io.prompt "Database host", :default => "vvv"
        end

        db_host
      end

      def db_name
        return false if @project.no_db || @project.no_wp

        if @project.skip_db || @project.use_defaults
          db_name = "#{clean_name}_db"
        else
          db_name = @io.prompt "Database name", :default => "#{clean_name}_db"
        end

        db_name
      end

      def db_user
        return false if @project.no_db || @project.no_wp

        if @project.skip_db || @project.use_defaults
          db_user = "#{clean_name}_user"
        else
          db_user = @io.prompt "Database username", :default => "#{clean_name}_user"
        end

        db_user
      end

      def db_pass
        return false if @project.no_db || @project.no_wp

        pass = Faker::Internet.password 24

        if @project.skip_db || @project.use_defaults
          db_pass = pass
        else
          db_pass = @io.prompt "Database password", :default => pass
        end

        db_pass
      end

      def db_import
        return false if @project.no_db || @project.no_wp

        if @io.agree? "Would you like to import an existing database?"
          db = @io.prompt "Where is the database file?", {
            :indent => 2, :path => true }
        else
          db = false
        end

        db
      end
    end
  end
end
