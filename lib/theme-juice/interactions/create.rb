# # encoding: UTF-8
#
# module ThemeJuice
#   module IOions::Create
#
#     @env = ::ThemeJuice::Env
#     @io = ::ThemeJuice::IO
#
#     class << self
#
#       #
#       # Set up needed site options
#       #
#       # @param {Hash} opts
#       #
#       # @return {Hash}
#       #
#       def setup_project_options(opts = {})
#         @opts = opts
#
#         if @env.yolo
#           @opts[:use_defaults] = true
#         end
#
#         @opts[:project_name]          ||= setup_project_name
#         @opts[:project_name_clean]    ||= setup_project_name_clean
#         @opts[:project_location]      ||= setup_project_location
#         @opts[:project_starter_theme] ||= setup_project_starter_theme
#         @opts[:project_dev_location]  ||= setup_project_dev_location
#         @opts[:project_dev_url]       ||= setup_project_dev_url
#         @opts[:project_repository]    ||= setup_project_repository
#         @opts[:project_db_host]       ||= setup_project_db_host
#         @opts[:project_db_name]       ||= setup_project_db_name
#         @opts[:project_db_user]       ||= setup_project_db_user
#         @opts[:project_db_pass]       ||= setup_project_db_pass
#
#         # Verify that all the options are correct
#         @io.list "Your settings :", :yellow, [
#           "Project name: #{@opts[:project_name]}",
#           "Project location: #{@opts[:project_location]}",
#           "Starter theme: #{@opts[:project_starter_theme]}",
#           "Development location: #{@opts[:project_dev_location]}",
#           "Development url: http://#{@opts[:project_dev_url]}",
#           "Initialized repository: #{@opts[:project_repository]}",
#           "Database host: #{@opts[:project_db_host]}",
#           "Database name: #{@opts[:project_db_name]}",
#           "Database username: #{@opts[:project_db_user]}",
#           "Database password: #{@opts[:project_db_pass]}"
#         ]
#
#         unless @io.agree? "Do the options above look correct?"
#           @io.error "Dang typos... aborting mission."
#         end
#
#         @opts
#       end
#
#       private
#
#       #
#       # Site name
#       #
#       # @return {String}
#       #
#       def setup_project_name
#         if @env.yolo
#           name = Faker::Internet.domain_word
#         else
#           name = @io.prompt "What's the project name? (letters, numbers and dashes only)"
#         end
#
#         validate_project_name name
#
#         name
#       end
#
#       #
#       # Clean site name for database naming
#       #
#       # @return {String}
#       #
#       def setup_project_name_clean
#         "#{@opts[:project_name]}".gsub(/[^\w]/, "_")[0..10]
#       end
#
#       #
#       # Site local location
#       #
#       # @return {String}
#       #
#       def setup_project_location
#         path = "#{Dir.pwd}/"
#
#         if @opts[:use_defaults]
#           location = File.expand_path(path)
#         else
#           location = File.expand_path(@io.prompt "Where do you want to setup the project?", :default => path, :path => true)
#         end
#
#         location
#       end
#
#       #
#       # Site starter theme
#       #
#       # @return {String}
#       #
#       def setup_project_starter_theme
#         if @opts[:project_bare]
#           theme = false
#         else
#           themes = {
#             "theme-juice/theme-juice-starter" => "https://github.com/ezekg/theme-juice-starter.git",
#             "other" => nil,
#             "none"  => false
#           }
#
#           if @opts[:use_defaults]
#             return themes["theme-juice/theme-juice-starter"]
#           end
#
#           choice = @io.choose "Which starter theme would you like to use?", :blue, themes.keys
#
#           case choice
#           when "theme-juice/theme-juice-starter"
#             @io.success "Awesome choice!"
#           when "other"
#             themes[choice] = @io.prompt "What is the repository URL for the starter theme that you would like to clone?"
#           when "none"
#             @io.notice "Next time you need to create a project without a starter theme, you can just run the 'setup' command instead."
#             @opts[:project_bare] = true
#           end
#
#           theme = themes[choice]
#         end
#
#         theme
#       end
#
#       #
#       # Site development location
#       #
#       # @return {String}
#       #
#       def setup_project_dev_location
#         dev_location = File.expand_path("#{@env.vm_path}/www/tj-#{@opts[:project_name]}")
#       end
#
#       #
#       # Site development url
#       #
#       # @return {String}
#       #
#       def setup_project_dev_url
#         if @opts[:use_defaults]
#           url = "#{@opts[:project_name]}.dev"
#         else
#           url = @io.prompt "What do you want the development url to be? (this should end in '.dev')", :default => "#{@opts[:project_name]}.dev"
#         end
#
#         validate_project_dev_url url
#
#         url
#       end
#
#       #
#       # Site repository
#       #
#       # @return {String}
#       #
#       def setup_project_repository
#         if @opts[:use_defaults] || @opts[:skip_repo]
#           repo = false
#         else
#           if @io.agree? "Would you like to initialize a new Git repository?"
#             repo = @io.prompt "What is the repository's URL?", :indent => 2
#           else
#             repo = false
#           end
#         end
#
#         repo
#       end
#
#       #
#       # Database host
#       #
#       # @return {String}
#       #
#       def setup_project_db_host
#         if @opts[:use_defaults] || @opts[:skip_db]
#           db_host = "vvv"
#         else
#           db_host = @io.prompt "Database host", :default => "vvv"
#         end
#
#         db_host
#       end
#
#       #
#       # Database name
#       #
#       # @return {String}
#       #
#       def setup_project_db_name
#         if @opts[:use_defaults] || @opts[:skip_db]
#           db_name = "#{@opts[:project_name_clean]}_db"
#         else
#           db_name = @io.prompt "Database name", :default => "#{@opts[:project_name_clean]}_db"
#         end
#
#         db_name
#       end
#
#       #
#       # Database username
#       #
#       # @return {String}
#       #
#       def setup_project_db_user
#         if @opts[:use_defaults] || @opts[:skip_db]
#           db_user = "#{@opts[:project_name_clean]}_user"
#         else
#           db_user = @io.prompt "Database username", :default => "#{@opts[:project_name_clean]}_user"
#         end
#
#         db_user
#       end
#
#       #
#       # Database password
#       #
#       # @return {String}
#       #
#       def setup_project_db_pass
#         pass = Faker::Internet.password 24
#
#         if @opts[:use_defaults] || @opts[:skip_db]
#           db_pass = pass
#         else
#           db_pass = @io.prompt "Database password", :default => pass
#         end
#
#         db_pass
#       end
#
#       #
#       # Validate site name
#       #
#       # @param {String} name
#       #
#       # @return {Void}
#       #
#       def validate_project_name(name)
#         if name.empty?
#           @io.error "Project name '#{name}' is invalid or empty. Aborting mission."
#         end
#
#         "#{name}".match /[^0-9A-Za-z.\-]/ do |char|
#           @io.error "Project name contains an invalid character '#{char}'. This name is used for creating directories, so that's not gonna work. Aborting mission."
#         end
#       end
#
#       #
#       # Validate site url
#       #
#       # @param {String} url
#       #
#       # @return {Void}
#       #
#       def validate_project_dev_url(url)
#         unless "#{url}".match /(.dev)$/
#           @io.error "Your development url '#{url}' doesn't end with '.dev'. This is used internally by Landrush, so that's not gonna work. Aborting mission."
#         end
#       end
#     end
#   end
# end
