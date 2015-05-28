# encoding: UTF-8

module ThemeJuice
  class CLI < Thor

    def initialize(*)
      super

      @version = VERSION
      @env     = Env
      @io      = IO
      @config  = Config
      @project = Project
      @util    = Util.new
      @list    = Tasks::List
      @create  = Commands::Create
      @delete  = Commands::Delete
      @deploy  = Commands::Deploy

      init_env
    end

    no_commands do
      def init_env
        @env.vm_path       = options[:vm_path]
        @env.vm_ip         = options[:vm_ip]
        @env.vm_prefix     = options[:vm_prefix]
        @env.yolo          = options[:yolo]
        @env.boring        = options[:boring]
        @env.no_unicode    = options[:no_unicode]
        @env.no_colors     = options[:no_colors]
        @env.no_animations = options[:no_animations]
        @env.no_landrush   = options[:no_landrush]
        @env.verbose       = options[:verbose]
        @env.dryrun        = options[:dryrun]
      end
    end

    map %w[--version -v]           => :version
    map %w[mk new]                 => :create
    map %w[up init]                => :setup
    map %w[rm remove trash]        => :delete
    map %w[ls projects apps sites] => :list
    map %w[build]                  => :install
    map %w[dev]                    => :watch
    map %w[deps]                   => :vendor
    map %w[zip package pkg]        => :dist
    map %w[wordpress]              => :wp
    map %w[bk]                     => :backup
    map %w[tests spec specs]       => :test
    map %w[server remote]          => :deploy
    map %w[vagrant vvv]            => :vm

    class_option :vm_path,       :type => :string,  :default => nil,         :desc => "Force path to VM"
    class_option :vm_ip,         :type => :string,  :default => nil,         :desc => "Force IP address for VM"
    class_option :vm_prefix,     :type => :string,  :default => nil,         :desc => "Force directory prefix for project in VM"
    class_option :yolo,          :type => :boolean,                          :desc => "Say yes to anything and everything"
    class_option :boring,        :type => :boolean,                          :desc => "Disable all the coolness"
    class_option :no_unicode,    :type => :boolean,                          :desc => "Disable all unicode characters"
    class_option :no_colors,     :type => :boolean,                          :desc => "Disable all colored output"
    class_option :no_animations, :type => :boolean,                          :desc => "Disable all animations"
    class_option :no_landrush,   :type => :boolean,                          :desc => "Disable landrush for DNS"
    class_option :verbose,       :type => :boolean,                          :desc => "Enable verbose output"
    class_option :dryrun,        :type => :boolean, :aliases => "--dry-run", :desc => "Disable executing any commands"

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
    method_option :db_import,    :type => :string,  :aliases => %w[-i --import-db],    :desc => "Import an existing database"
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
    method_option :db_import,    :type => :string,  :aliases => %w[-i --import-db],    :desc => "Import an existing database"
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
      @create.new(options.dup.merge({
        :theme => false,
        :bare => true,
      })).execute
    end

    desc "delete", "Delete project (does not delete local project)"
    method_option :name,       :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the project"
    method_option :url,        :type => :string,  :aliases => "-u", :default => nil, :desc => "Development URL for the project"
    method_option :db_drop,    :type => :boolean, :aliases => "--drop-db",           :desc => "Drop project's database"
    method_option :vm_restart, :type => :boolean, :aliases => "--restart-vm",        :desc => "Restart VM after deletion"
    #
    # @return {Void}
    #
    def delete
      @delete.new(options).unexecute
    end

    desc "deploy", "Manage deployment and migration"
    #
    # @return {Void}
    #
    def deploy
      @deploy.new(options).execute
    end

    desc "list", "List all projects"
    #
    # @return {Void}
    #
    def list
      @list.new(options).list :projects
    end

    desc "update", "Update tj and its dependencies"
    #
    # @return {Void}
    #
    def update(*commands)
      @io.error "Not implemented"
    end

    desc "install", "Run installation for project"
    #
    # @return {Void}
    #
    def install(*commands)
      @config.install commands
    end

    desc "watch [COMMANDS]", "Watch and compile assets"
    #
    # @return {Void}
    #
    def watch(*commands)
      @config.watch commands
    end

    desc "vendor [COMMANDS]", "Manage vendor dependencies"
    #
    # @return {Void}
    #
    def vendor(*commands)
      @config.vendor commands
    end

    desc "dist [COMMANDS]", "Package project for distribution"
    #
    # @return {Void}
    #
    def dist(*commands)
      @config.dist commands
    end

    desc "wp [COMMANDS]", "Manage WordPress installation"
    #
    # @return {Void}
    #
    def wp(*commands)
      @config.wp commands
    end

    desc "backup [COMMANDS]", "Backup project"
    #
    # @return {Void}
    #
    def backup(*commands)
      @config.backup commands
    end

    desc "test [COMMANDS]", "Manage and run project tests"
    #
    # @return {Void}
    #
    def test(*commands)
      @config.test commands
    end

    desc "vm [COMMANDS]", "Manage development environment"
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
