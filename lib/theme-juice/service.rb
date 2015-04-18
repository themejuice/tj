# # encoding: UTF-8
#
# module ThemeJuice
#   class Service
#     include ::Thor::Actions
#     include ::Thor::Shell
#
#     #
#     # @param {Hash} opts
#     #
#     def initialize(opts)
#       @env          = ::ThemeJuice::Env
#       @interact     = ::ThemeJuice::Interact
#       @opts         = opts
#       @config_path  = opts[:project_location] || Dir.pwd
#       @config_regex = %r{^(\.)?(tj.y(a)?ml)}
#     rescue => err
#       @interact.error "Whoops! Something went wrong!" do
#         puts err
#       end
#     end
#
#     private
#
#     #
#     # Run system commands
#     #
#     # @param {Array} commands
#     #   Array of commands to run
#     # @param {Bool}  silent   (true)
#     #   Silence all output from command
#     #
#     # @return {Void}
#     #
#     def run(commands, silent = true)
#       commands.map! { |cmd| cmd.to_s + " > /dev/null 2>&1" } if silent
#       system commands.join "&&"
#     end
#
#     #
#     # Verify config is properly setup and load it
#     #
#     # @return {Void}
#     #
#     def load_config
#
#       if config_is_setup?
#         @config = YAML.load_file(Dir["#{@config_path}/*"].select { |f| @config_regex =~ File.basename(f) }.last)
#       else
#         @interact.notice "Unable to find a 'tj.yml' file in '#{@config_path}'."
#
#         unless @interact.agree? "Would you like to create one?"
#           @interact.error "A config file is needed to continue. Aborting mission."
#         end
#
#         setup_config
#       end
#     end
#
#     #
#     # Restart Vagrant
#     #
#     # @note Normally a simple 'vagrant reload' would work, but Landrush requires
#     #   a 'vagrant up' to be fired for it to set up the DNS correctly.
#     #
#     # @return {Void}
#     #
#     def restart_vagrant
#       @interact.log "Restarting VVV"
#
#       # Halt if already running
#       run ["cd #{@env.vm_path}", "vagrant halt"]
#
#       # Up, up, up!
#       if run ["cd #{@env.vm_path}", "vagrant up --provision"], false
#         true
#       else
#         false
#       end
#     end
#
#     #
#     # Test if site creation was successful
#     #
#     # @return {Bool}
#     #
#     def setup_was_successful?
#       vvv_is_setup? and dev_project_is_setup? and hosts_is_setup? and database_is_setup? and nginx_is_setup?
#     end
#
#     #
#     # Test if site removal was successful. This just reverses the check
#     #  for a successful setup.
#     #
#     # @return {Bool}
#     #
#     def removal_was_successful?
#       !setup_was_successful?
#     end
#
#     #
#     # Test if project directory tree has been created
#     #
#     # @return {Bool}
#     #
#     def project_dir_is_setup?
#       Dir.exist? "#{@opts[:project_location]}"
#     end
#
#     #
#     # Test if config file is in current working directory
#     #
#     # @return {Bool}
#     #
#     def config_is_setup?
#       !Dir["#{@config_path}/*"].select { |f| @config_regex =~ File.basename(f) }.empty?
#     end
#
#     #
#     # Test if VVV has been cloned
#     #
#     # @return {Bool}
#     #
#     def vvv_is_setup?
#       File.exist? File.expand_path(@env.vm_path)
#     end
#
#     #
#     # Test if landrush block has been placed
#     #
#     # @return {Bool}
#     #
#     def wildcard_subdomains_is_setup?
#       File.readlines(File.expand_path("#{@env.vm_path}/Vagrantfile")).grep(/(config.landrush.enabled = true)/m).any?
#     end
#
#     #
#     # Test if VVV development location has been created
#     #
#     # @return {Bool}
#     #
#     def dev_project_is_setup?
#       File.exist? "#{@opts[:project_dev_location]}"
#     end
#
#     #
#     # Test if hosts file has been created
#     #
#     # @return {Bool}
#     #
#     def hosts_is_setup?
#       File.exist? "#{@opts[:project_location]}/vvv-hosts"
#     end
#
#     #
#     # Test if database block has been placed
#     #
#     # @return {Bool}
#     #
#     def database_is_setup?
#       File.readlines(File.expand_path("#{@env.vm_path}/database/init-custom.sql")).grep(/(#(#*)? Begin '#{@opts[:project_name]}')/m).any?
#     end
#
#     #
#     # Test if nginx config has been created
#     #
#     # @return {Bool}
#     #
#     def nginx_is_setup?
#       File.exist? "#{@opts[:project_location]}/vvv-nginx.conf"
#     end
#
#     #
#     # Test if starter theme has been set up by checking for common
#     #  WordPress directories
#     #
#     # @return {Bool}
#     #
#     def starter_theme_is_setup?
#       !Dir["#{@opts[:project_location]}/*"].select { |f| %r{wp(-content)?|wordpress|app|public|web|content} =~ File.basename(f) }.empty?
#     end
#
#     #
#     # Test if synced folder block has been placed
#     #
#     # @return {Bool}
#     #
#     def synced_folder_is_setup?
#       File.readlines(File.expand_path("#{@env.vm_path}/Vagrantfile")).grep(/(#(#*)? Begin '#{@opts[:project_name]}')/m).any?
#     end
#
#     #
#     # Test if repository has been set up
#     #
#     # @return {Bool}
#     #
#     def repo_is_setup?
#       File.exist? File.expand_path("#{@opts[:project_location]}/.git")
#     end
#
#     #
#     # Test if .env file has been created
#     #
#     # @return {Bool}
#     #
#     def env_is_setup?
#       File.exist? File.expand_path("#{@opts[:project_location]}/.env.development")
#     end
#
#     #
#     # Test if local wp-cli file has been created
#     #
#     # @return {Bool}
#     #
#     def wpcli_is_setup?
#       File.exist? File.expand_path("#{@opts[:project_location]}/wp-cli.local.yml")
#     end
#
#     #
#     # Test if we're initializing a new repository
#     #
#     # @return {Bool}
#     #
#     def using_repo?
#       !!@opts[:project_repository]
#     end
#   end
# end
