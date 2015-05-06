# encoding: UTF-8

#
# Monkey patch to not print out reverse bool options on --help
#
# @see https://github.com/erikhuda/thor/issues/417
#
class Thor
  class Option < Argument
    def usage(padding = 0)
      sample = if banner && !banner.to_s.empty?
        "#{switch_name}=#{banner}"
      else
        switch_name
      end

      sample = "[#{sample}]" unless required?

      # if boolean?
      #   sample << ", [#{dasherize("no-" + human_name)}]" unless name == "force" or name.start_with?("no-")
      # end

      if aliases.empty?
        (" " * padding) << sample
      else
        "#{aliases.join(', ')}, #{sample}"
      end
    end

    VALID_TYPES.each do |type|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type}?
          self.type == #{type.inspect}
        end
      RUBY
    end
  end
end

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
      @env.vm_path       = options.fetch "vm_path",       ENV.fetch("TJ_VM_PATH", File.expand_path("~/vagrant"))
      @env.vm_ip         = options.fetch "vm_ip",         ENV.fetch("TJ_VM_IP", "192.168.50.4")
      @env.vm_prefix     = options.fetch "vm_prefix",     ENV.fetch("TJ_VM_PREFIX", "tj-")
      @env.yolo          = options.fetch "yolo",          ENV.fetch("TJ_YOLO", false)
      @env.boring        = options.fetch "boring",        ENV.fetch("TJ_BORING", false)
      @env.no_unicode    = options.fetch "no_unicode",    ENV.fetch("TJ_NO_UNICODE", @env.boring)
      @env.no_colors     = options.fetch "no_colors",     ENV.fetch("TJ_NO_COLORS", @env.boring)
      @env.no_animations = options.fetch "no_animations", ENV.fetch("TJ_NO_ANIMATIONS", @env.boring)
      @env.no_landrush   = options.fetch "no_landrush",   ENV.fetch("TJ_NO_LANDRUSH", false)
      @env.verbose       = options.fetch "verbose",       ENV.fetch("TJ_VERBOSE", false)
      @env.dryrun        = options.fetch "dryrun",        ENV.fetch("TJ_DRYRUN", false)
    end

    map %w[--version -v]             => :version
    map %w[mk make new add]          => :create
    map %w[up prep init]             => :setup
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
    method_option :import_db,    :type => :string,  :aliases => "-i",                  :desc => "Import an existing database"
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
    method_option :name,       :type => :string,  :aliases => "-n", :default => nil, :desc => "Name of the development project"
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
