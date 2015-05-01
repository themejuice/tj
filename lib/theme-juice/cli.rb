# encoding: UTF-8

module ThemeJuice
  class CLI < Thor

    def initialize(*)
      super

      @version           = VERSION
      @env               = Env
      @io                = IO
      @config            = Config
      @project           = Project
      @util              = Util.new
      @list              = Tasks::List
      @create            = Commands::Create
      @delete            = Commands::Delete
      @deploy            = Commands::Deploy
      @env.vm_path       = options.fetch("vm_path", File.expand_path("~/vagrant"))
      @env.vm_ip         = options.fetch("vm_ip", "192.168.50.4")
      @env.vm_prefix     = options.fetch("vm_prefix", "tj-")
      @env.yolo          = options.fetch("yolo", false)
      @env.boring        = options.fetch("boring", false)
      @env.no_unicode    = @env.boring ? true : options.fetch("no_unicode", false)
      @env.no_colors     = @env.boring ? true : options.fetch("no_colors", false)
      @env.no_animations = @env.boring ? true : options.fetch("no_animations", false)
      @env.no_landrush   = options.fetch("no_landrush", false)
      @env.verbose       = options.fetch("verbose", false)
      @env.dryrun        = options.fetch("dryrun", false)
    end

    map %w[--version -v]             => :version
    map %w[mk new add]               => :create
    map %w[up build prep init make]  => :setup
    map %w[rm remove trash teardown] => :delete
    map %w[ls projects apps sites]   => :list
    map %w[assets dev build]         => :watch
    map %w[dependencies deps]        => :vendor
    map %w[distrubute pack package]  => :dist
    map %w[wordpress]                => :wp
    map %w[bk]                       => :backup
    map %w[tests spec specs]         => :test
    map %w[deployer server remote]   => :deploy
    map %w[vagrant vvv]              => :vm

    class_option :vm_path,       :type => :string,  :default => nil, :desc => "Force path to VM"
    class_option :vm_ip,         :type => :string,  :default => nil, :desc => "Force IP address for VM"
    class_option :vm_prefix,     :type => :string,  :default => nil, :desc => "Force directory prefix for project in VM"
    class_option :yolo,          :type => :boolean,                  :desc => "Say yes to anything and everything"
    class_option :boring,        :type => :boolean,                  :desc => "Disable all the coolness"
    class_option :no_unicode,    :type => :boolean,                  :desc => "Disable all unicode characters"
    class_option :no_colors,     :type => :boolean,                  :desc => "Disable all colored output"
    class_option :no_animations, :type => :boolean,                  :desc => "Disable all animations"
    class_option :no_landrush,   :type => :boolean,                  :desc => "Disable landrush for DNS"
    class_option :verbose,       :type => :boolean,                  :desc => "Verbose output"
    class_option :dryrun,        :type => :boolean,                  :desc => "Disable running all commands"

    desc "--version, -v", "Print current version"
    #
    # @return {String}
    #
    def version
      @io.speak @version, :color => :green
    end

    desc "create", "Create new project"
    method_option :name,         :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the project"
    method_option :location,     :type => :string,  :aliases => "-l", :default => nil, :desc => "Location of the local project"
    method_option :theme,        :type => :string,  :aliases => "-t", :default => nil, :desc => "Starter theme to install"
    method_option :url,          :type => :string,  :aliases => "-u", :default => nil, :desc => "Development URL for the project"
    method_option :repository,   :type => :string,  :aliases => "-r",                  :desc => "Initialize a new Git remote repository"
    method_option :bare,         :type => :boolean,                                    :desc => "Create a project without a starter theme"
    method_option :skip_repo,    :type => :boolean,                                    :desc => "Skip repository prompts and use default settings"
    method_option :skip_db,      :type => :boolean,                                    :desc => "Skip database prompts and use default settings"
    method_option :use_defaults, :type => :boolean,                                    :desc => "Skip all prompts and use default settings"
    method_option :no_wp,        :type => :boolean,                                    :desc => "New project is not a WordPress install"
    method_option :no_db,        :type => :boolean,                                    :desc => "New project does not need a database"
    #
    # @return {Void}
    #
    def create
      @io.hello
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
      @io.hello
      @create.new(options.dup.merge(:bare => true)).execute
    end

    desc "delete [NAME]", "Delete project (does not delete local project)"
    method_option :name,    :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the development project"
    method_option :drop_db, :type => :boolean,                                    :desc => "Drop project's database"
    method_option :restart, :type => :boolean,                                    :desc => "Restart development environment after deletion"
    #
    # @param {String} name (nil)
    #
    # @return {Void}
    #
    def delete
      @delete.new(options).unexecute
    end

    desc "list", "List all projects"
    #
    # @return {Void}
    #
    def list
      @list.new(options).list :projects
    end

    desc "install", "Run installation for the starter theme"
    #
    # @return {Void}
    #
    def install
      @config.install
    end

    desc "share", "Share project with Vagrant Share"
    #
    # @return {Void}
    #
    def share
      @io.error "Not implemented"
    end

    desc "module [COMMANDS]", "Manage project modules"
    #
    # @return {Void}
    #
    def module
      @io.error "Not implemented"
    end

    desc "skin [COMMANDS]", "Manage project skins"
    #
    # @return {Void}
    #
    def skin
      @io.error "Not implemented"
    end

    desc "update", "Update tj and its dependencies"
    #
    # @return {Void}
    #
    def update
      @io.error "Not implemented"
    end

    desc "watch [COMMANDS]", "Watch and compile assets"
    #
    # @param {*} commands
    #
    # @return {Void}
    #
    def watch(*commands)
      @config.watch *commands
    end

    desc "vendor [COMMANDS]", "Manage vendor dependencies"
    #
    # @param {*} commands
    #
    # @return {Void}
    #
    def vendor(*commands)
      @config.vendor *commands
    end

    desc "dist [COMMANDS]", "Package project for distribution"
    #
    # @return {Void}
    #
    def dist(*commands)
      @config.dist *commands
    end

    desc "wp [COMMANDS]", "Manage WordPress installation"
    #
    # @return {Void}
    #
    def wp(*commands)
      @config.wp *commands
    end

    desc "backup [COMMANDS]", "Run backup command"
    #
    # @return {Void}
    #
    def backup(*commands)
      @config.backup *commands
    end

    desc "test [COMMANDS]", "Manage and run project tests"
    #
    # @return {Void}
    #
    def test(*commands)
      @config.test *commands
    end

    desc "deploy [COMMANDS]", "Manage deployment and migration"
    #
    # @param {*} commands
    #
    # @return {Void}
    #
    def deploy(*commands)
      @deploy.new(options).execute
    end

    desc "vm [COMMANDS]", "Manage development environment"
    #
    # @param {*} commands
    #
    # @return {Void}
    #
    def vm(*commands)
      @util.inside @env.vm_path do
        @util.run "vagrant #{commands.join(" ")}", :verbose => @env.verbose
      end
    end
  end
end
