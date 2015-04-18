# encoding: UTF-8

module ThemeJuice
  class CLI < Thor

    #
    # Command aliases
    #
    map %w[--version -v]                => :version
    map %w[mk new add]                  => :create
    map %w[up prep init]                => :setup
    map %w[rm remove trash teardown]    => :delete
    map %w[pack distrubute dist]        => :package
    map %w[ls projects apps sites show] => :list
    map %w[assets dev build make]       => :watch
    map %w[dependencies deps]           => :vendor
    map %w[deploy server remote]        => :deployer
    map %w[vagrant vvv]                 => :vm

    #
    # Class options
    #
    class_option :vvv_path,      :type => :string,  :default => nil, :desc => "Force path to VVV installation"
    class_option :yolo,          :type => :boolean,                  :desc => "Say yes to anything and everything"
    class_option :boring,        :type => :boolean,                  :desc => "Disable all the coolness"
    class_option :no_unicode,    :type => :boolean,                  :desc => "Disable all unicode characters"
    class_option :no_colors,     :type => :boolean,                  :desc => "Disable all colored output"
    class_option :no_animations, :type => :boolean,                  :desc => "Disable all animations"
    class_option :no_deployer,   :type => :boolean,                  :desc => "Disable deployer"

    desc "--version, -v", "Print current version"
    #
    # Print current version
    #
    # @return {String}
    #
    def version
      @interact.speak @version, :color => :green
    end

    desc "create", "Create new project"
    method_option :name,         :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the project"
    method_option :location,     :type => :string,  :aliases => "-l", :default => nil, :desc => "Location of the local project"
    method_option :theme,        :type => :string,  :aliases => "-t", :default => nil, :desc => "Starter theme to install"
    method_option :url,          :type => :string,  :aliases => "-u", :default => nil, :desc => "Development URL for the project"
    method_option :repository,   :type => :string,  :aliases => "-r",                  :desc => "Initialize a new Git remote repository"
    method_option :bare,         :type => :boolean,                                    :desc => "Create a VVV project without a starter theme"
    method_option :skip_repo,    :type => :boolean,                                    :desc => "Skip repository prompts and use default settings"
    method_option :skip_db,      :type => :boolean,                                    :desc => "Skip database prompts and use default settings"
    method_option :use_defaults, :type => :boolean,                                    :desc => "Skip all prompts and use default settings"
    method_option :no_wp,        :type => :boolean,                                    :desc => "New project is not a WordPress install"
    method_option :no_db,        :type => :boolean,                                    :desc => "New project does not need a database"
    #
    # @return {Void}
    #
    def create
      @interact.hello
      @create.new(options).execute
    end

    desc "setup", "Setup existing project"
    method_option :name,         :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the project"
    method_option :location,     :type => :string,  :aliases => "-l", :default => nil, :desc => "Location of the local project"
    method_option :url,          :type => :string,  :aliases => "-u", :default => nil, :desc => "Development URL for the project"
    method_option :repository,   :type => :string,  :aliases => "-r",                  :desc => "Initialize a new Git remote repository"
    method_option :skip_repo,    :type => :boolean,                                    :desc => "Skip repository prompts and use default settings"
    method_option :skip_db,      :type => :boolean,                                    :desc => "Skip database prompts and use default settings"
    method_option :use_defaults, :type => :boolean,                                    :desc => "Skip all prompts and use default settings"
    method_option :no_wp,        :type => :boolean,                                    :desc => "New project is not a WordPress install"
    method_option :no_db,        :type => :boolean,                                    :desc => "New project does not need a database"
    #
    # @return {Void}
    #
    def setup
      @interact.hello
      @create.new(options.dup.merge(:bare => true)).execute
    end

    desc "delete [NAME]", "Remove project (does not remove local project)"
    method_option :name,    :type => :string,  :aliases => "-n", :default => false, :desc => "Name of the development project"
    method_option :restart, :type => :boolean,                                      :desc => "Restart development environment after deletion"
    #
    # @param {String} name (nil)
    #   Project to delete. This will not delete your local files, only
    #     files within the VVV environment
    #
    # @return {Void}
    #
    def delete(name = nil)
      @project.name         = name || options[:name]
      @project.dev_location = nil
      @project.restart      = options[:restart]

      @delete.new.execute
    end

    desc "list", "List all projects"
    #
    # @return {Void}
    #
    def list
      @list.new.execute
    end

    desc "install", "Run installation for the starter theme"
    #
    # @return {Void}
    #
    def install
      @install.new.execute
    end

    desc "share", "Share project with Vagrant Share"
    #
    # @return {Void}
    #
    def share
    end

    desc "package", "Package project for distribution"
    #
    # @return {Void}
    #
    def package
    end

    desc "module", "Manage project modules"
    #
    # @return {Void}
    #
    def module
    end

    desc "skin", "Manage project skins"
    #
    # @return {Void}
    #
    def skin
    end

    desc "test", "Manage and run project tests"
    #
    # @return {Void}
    #
    def test
    end

    desc "update", "Update tj and its dependencies"
    #
    # @return {Void}
    #
    def update
    end

    desc "watch [COMMANDS]", "Watch and compile assets"
    #
    # @param {*} commands
    #   Commands to run
    #
    # @return {Void}
    #
    def watch(*commands)
      opts = {
        :subcommand => "watch",
        :commands   => commands.join(" ")
      }

      @subcommand.new(opts)
    end

    desc "vendor [COMMANDS]", "Manage vendor dependencies"
    #
    # @param {*} commands
    #   Commands to run
    #
    # @return {Void}
    #
    def vendor(*commands)
      opts = {
        :subcommand => "vendor",
        :commands   => commands.join(" ")
      }

      @subcommand.new(opts)
    end

    desc "deployer [COMMANDS]", "Manage deployment and migration"
    #
    # @param {*} commands
    #   Commands to run
    #
    # @return {Void}
    #
    def deployer(*commands)
      if @deployer
        opts = {
          :stage    => commands[0],
          :commands => commands[1..-1],
        }

        case commands.length
        when 1
          @interact.error "You did not specify any commands to execute on '#{opts[:stage]}'. Aborting mission."
        when 0
          @interact.error "You did not specify a stage or any commands to execute. Aborting mission."
        else
          @deployer.new(opts[:stage]).execute(opts[:commands])
        end
      else
        opts = {
          :subcommand => "server",
          :commands   => commands.join(" ")
        }

        @subcommand.new(opts)
      end
    end

    desc "vm [COMMANDS]", "Manage development environment (alias for 'vagrant' commands)"
    #
    # @param {*} commands
    #   Commands to run
    #
    # @return {Void}
    #
    def vm(*commands)
      system "cd #{@env.vvv_path} && vagrant #{commands.join(" ")}"
    end

    #
    # Non-Thor commands
    #
    no_commands do

      #
      # Initializer
      #
      def initialize(*args)
        super(*args)
        self.set_environment
      end

      #
      # Set up the environment
      #
      # @return {Void}
      #
      def set_environment
        @version    = VERSION
        @env        = Env
        @interact   = Interact
        @project    = Project
        @create     = Commands::Create
        @delete     = nil # ::ThemeJuice::Command::Delete
        @list       = nil # ::ThemeJuice::Command::List
        @install    = nil # ::ThemeJuice::Command::Install
        @subcommand = nil # ::ThemeJuice::Command::Subcommand
        @deployer   = nil # ::ThemeJuice::Command::Deployer

        # Check if we're forcing a different VVV path
        self.force_vvv_path?

        @env.yolo          = options[:yolo]
        @env.boring        = options[:boring]
        @env.no_deployer   = options[:no_deployer]
        @env.no_colors     = options[:boring] ? true : options[:no_colors]
        @env.no_unicode    = options[:boring] ? true : options[:no_unicode]
        @env.no_animations = options[:boring] ? true : options[:no_animations]
        @env.vm_prefix     = "tj"

        # if self.deployer?
        #   @deployer = ::ThemeJuice::Deploy::Deployer
        # else
        #   @deployer = false
        # end
      end

      #
      # Load deployer if installed
      #
      # @return {Bool}
      #
      # def deployer?
      #   if @env.no_deployer
      #     false
      #   else
      #     begin
      #       require "theme-juice-deploy"
      #       true
      #     rescue LoadError
      #       false
      #     end
      #   end
      # end

      #
      # Set VVV path
      #
      # @return {Void}
      #
      def force_vvv_path?
        if options[:vvv_path].nil?
          @env.vvv_path = File.expand_path("~/vagrant")
        else
          @env.vvv_path = options[:vvv_path]
          @interact.notice "You're using a custom VVV path : (#{@env.vvv_path})"

          unless @interact.agree? "Is this path correct?"
            @interact.error "Good call! Let's create things, not break things. Aborting mission."
          end
        end

        unless Dir.exist? @env.vvv_path
          @interact.error "Cannot load VVV path (#{@env.vvv_path}). Aborting mission before something bad happens."
        end
      end
    end
  end
end
